require 'securerandom'
require 'aws-sdk-ssm'
require 'aws-sdk-s3'

class RemoteTask::Drivers::AwsSsm < RemoteTask::Drivers::Base
  class UnexpectedError < StandardError; end
  class ScriptRequired < StandardError; end

  def self.poll?
    ENV['IOI_SSM_PROCESS_EVENTS'] != '1'
  end

  def self.make_ssm_client(region: nil)
    Aws::SSM::Client.new(
      region: region || Rails.application.config.x.remote_task.driver.aws_ssm.region,
      logger: Rails.logger,
    )
  end
  class_attribute :ssm, default: make_ssm_client()

  def self.make_s3_client(region: nil)
    Aws::S3::Client.new(
      region: region || Rails.application.config.x.remote_task.driver.aws_ssm.scratch_s3_region,
      logger: Rails.logger,
    )
  end
  class_attribute :s3, default: make_s3_client()

  def self.description_for(execution)
    "AWS SSM run for #{execution.target['instance_id']} @ #{execution.target['region'] || self.ssm.config.region}"
  end

  def initialize(*)
    super
    @instance_id = execution.target.fetch('instance_id')
    self.ssm = self.class.make_ssm_client(region: execution.target['region']) if execution.target['region'] && execution.target['region'] != self.class.ssm.config.region
    (execution.target['scratch_s3_region'] || execution.state&.fetch('scratch_s3_region', nil))&.tap do |s3_region|
      self.s3 = self.class.make_s3(region: s3_region) if s3_region != self.class.s3.config.region
    end
  end

  attr_reader :instance_id

  def execute!
    execution.state ||= {}
    prepare_scratch!
    send_command!
    if poll?
      poll!
    else
      update_status!
    end
    if ssm_finished? && !execution.finishing?
      clean_up!
      finalize!
    end
  end

  def poll?
    self.class.poll?
  end

  def prepare_scratch!
    return unless scratch
    return if execution.state['scratch_s3_region'] && execution.state['scratch_s3_bucket'] && execution.state['scratch_s3_key']
    execution.state['scratch_s3_region'] = s3.config.region
    execution.state['scratch_s3_bucket'] = execution.target['scratch_s3_bucket'] || Rails.application.config.x.remote_task.driver.aws_ssm.scratch_s3_bucket
    prefix = execution.target['scratch_s3_prefix'] || Rails.application.config.x.remote_task.driver.aws_ssm.scratch_s3_prefix
    execution.state['scratch_s3_key'] = "#{prefix}#{execution.task.id}_#{execution.id}_#{SecureRandom.urlsafe_base64(128)}"
    s3.put_object(
      bucket: execution.state.fetch('scratch_s3_bucket'),
      key: execution.state.fetch('scratch_s3_key'),
      body: scratch.read,
    )
  end

  def ssm_commands
    [
      'if [ -z $IOI_REEXEC ]; then export IOI_REEXEC=1; exec bash "$0" "$@" 2>&1; fi',
      'set -ex',
      scratch ? [
        'IOI_SCRATCH_PATH="$(tempfile -d /dev/shm -p ioic_ -s _ioi-console_remote-task-' + execution.task.id.to_s + '-' + execution.id.to_s + '_scratch -m 0600)"',
        "aws s3 cp --quiet --region #{execution.state.fetch('scratch_s3_region')} 's3://#{execution.state.fetch('scratch_s3_bucket')}/#{execution.state.fetch('scratch_s3_key')}' - > \"${IOI_SCRATCH_PATH}\"",
      ] : nil,
      script,
      scratch ? 'shred --remove "${IOI_SCRATCH_PATH}"' : nil,
      "\n",
    ].flatten.compact
  end

  def send_command!
    return if execution.state['command_id']
    raise ScriptRequired unless script
    resp = ssm.send_command(
      targets: [key: 'instanceids', values: [instance_id]],
      document_name: 'AWS-RunShellScript',
      document_version: '$DEFAULT',
      timeout_seconds: execution.target['timeout'] || 600,
      output_s3_bucket_name: Rails.application.config.x.remote_task.driver.aws_ssm.log_s3_bucket,
      output_s3_key_prefix: Rails.application.config.x.remote_task.driver.aws_ssm.log_s3_prefix,
      max_concurrency: 50.to_s,
      max_errors: 0.to_s,
      parameters: {
        'commands' => ssm_commands,
        'workingDirectory' => [execution.target['working_directory'] || '/'],
        'executionTimeout' => [(execution.target['timeout'] || 600).to_s],
      },
    )
    execution.state['command_id'] = resp.command.command_id
    execution.external_id = resp.command.command_id
    execution.status = :pending
    execution.save!
  end

  def update_status!(max_retry = 3)
    not_found_count = 0
    begin
      resp = ssm.get_command_invocation(
        command_id: execution.state.fetch('command_id'),
        instance_id: instance_id,
      )
    rescue Aws::SSM::Errors::InvocationDoesNotExist
      not_found_count += 1
      raise if not_found_count > max_retry
      sleep 2
      retry
    end

    execution.state['underlying_status'] = resp.status
    execution.state['underlying_status_details'] = resp.status_details
    execution.state['stdout_url'] = resp.standard_output_url
    execution.status = case resp.status
    when 'Pending', 'Delayed'
      :pending
    when 'InProgress', 'Cancelling'
      :running
    else
      execution.status
    end
    execution.save! unless ssm_finished?
  end

  def ssm_finished?
    %w(Success Failed TimedOut Cancelled).include? execution.state['underlying_status']
  end

  def poll!
    return if execution.finishing?
    loop do
      update_status!
      break if ssm_finished?
      sleep 2
    end
  end

  def clean_up!
    execution.update!(status: :cleaning)
    discard_scratch!
  end

  def discard_scratch!
    return unless execution.state['scratch_s3_region'] && execution.state['scratch_s3_bucket'] && execution.state['scratch_s3_key']
    s3.delete_object(
      bucket: execution.state.fetch('scratch_s3_bucket'),
      key: execution.state.fetch('scratch_s3_key'),
    )
  rescue Aws::S3::Errors::NotFound, Aws::S3::Errors::NoSuchKey
  end

  def finalize!
    execution.status = case execution.state['underlying_status']
    when 'Success'
      :succeeded
    when 'Failed', 'TimedOut'
      :failed
    when 'Cancelled'
      :cancelled
    else
      raise UnexpectedError, "Unknown SSM status #{execution.state.fetch('underlying_status')} on #{execution.state.fetch('command_id')} for #{instance_id}"
    end

    if execution.state['stdout_url'].present?
      url = Addressable::URI.parse(execution.state.fetch('stdout_url'))
      _, _bucket, key = url.path.split(?/, 3) # Assuming AWS SSM returns a path style URL :<
      execution.log_kind = 'AwsS3'
      execution.log = {
        'region' => Rails.application.config.x.remote_task.driver.aws_ssm.log_s3_region,
        'bucket' => Rails.application.config.x.remote_task.driver.aws_ssm.log_s3_bucket,
        'key' => key,
      }
    end

    execution.save!
  end
end
