require 'net/ssh'

class RemoteTask::Drivers::Ssh < RemoteTask::Drivers::Base
  class UnexpectedError < StandardError; end
  class ExecutionFailed < StandardError; end

  def self.make_s3_client(region: nil)
    Aws::S3::Client.new(
      region: region || Rails.application.config.x.remote_task.driver.ssh.log_s3_region,
      logger: Rails.logger,
    )
  end
  class_attribute :s3, default: make_s3_client()

  def self.description_for(execution)
    "SSH run for #{execution.target['hostname']}"
  end

  def initialize(*)
    super
    @hostname = execution.target.fetch('hostname')
    @user = execution.target.fetch('user', Rails.application.config.x.remote_task.driver.ssh.user)
  end

  attr_reader :hostname, :user

  def execute!
    execution.state ||= {}
    begin
      prepare_scratch!
      run_command!
      mark_success!
    rescue Net::SSH::Exception, ExecutionFailed => e
      mark_failure!(e)
    end
    upload_log!
  end

  def prepare_scratch!
    return unless scratch
    return if execution.state['scratch_path']

    execution.state['scratch_path'] = ssh.exec!('tempfile -d /dev/shm -p ioic_ -s _ioi-console_remote-task-' + execution.task.id.to_s + '-' + execution.id.to_s + '_scratch -m 0600').chomp
    ssh_run("cat > '#{execution.state['scratch_path']}'") do |ch|
      ch.send_data(scratch.read)
      ch.eof!
    end
    execution.save!
  end

  def ssh_command
    [
      'set -ex',
      scratch ? [
        "IOI_SCRATCH_PATH='#{execution.state.fetch('scratch_path')}'",
      ] : nil,
      script,
      scratch ? 'shred --remove "${IOI_SCRATCH_PATH}"' : nil,
      "\n",
    ].flatten.join(?\n)
  end

  def run_command!
    execution.status = :pending
    execution.save!
    ssh_run("bash") do |ch|
      set_ssh_output_hook(ch)
      ch.send_data(ssh_command)
      ch.eof!
      execution.status = :running
      execution.save!
    end
  end

  def mark_success!
    execution.update!(status: :succeeded)
  end

  def mark_failure!(e)
    execution.update!(status: :failed)
    logfile.puts "[EXCEPTION] #{e.inspect}\n\n#{e.full_message}"
  end

  def upload_log!
    finalize_log!
    execution.log_kind = 'AwsS3'
    execution.log = {
      'region' => s3.config.region,
      'bucket' => Rails.application.config.x.remote_task.driver.ssh.log_s3_bucket,
      'key' =>  "#{Rails.application.config.x.remote_task.driver.ssh.log_s3_prefix}#{execution.task.id}_#{execution.id}.log",
    }
    logfile(:read).rewind
    s3.put_object(
      bucket: execution.log.fetch('bucket'),
      key: execution.log.fetch('key'),
      body: logfile(:read),
    )
    execution.save!
  end


  def ssh_run(cmd, error: true)
    exitstatus, exitsignal = nil

    puts "$ #{cmd}"
    cha = ssh.open_channel do |ch|
      ch.exec(cmd) do |c, success|
        raise ExecutionFailed "execution failed on #{host.name}: #{cmd.inspect}" if !success && error

        c.on_request("exit-status") { |_c, data| exitstatus = data.read_long }
        c.on_request("exit-signal") { |_c, data| exitsignal = data.read_long }

        yield c if block_given?
      end
    end
    cha.wait
    raise ExecutionFailed "execution failed on #{host.name} (status=#{exitstatus.inspect}, signal=#{exitsignal.inspect}): #{cmd.inspect}" if (exitstatus != 0 || exitsignal) && error
    [exitstatus, exitsignal]
  end

  def ssh
    @ssh ||= Net::SSH.start(hostname, user, key_data: Rails.application.config.x.remote_task.driver.ssh.key_data)
  end

  def finalize_log!
    @logfile_finalized = true
    logfile(:force).flush
  end
  def logfile_finalized?
    @logfile_finalized
  end
  def logfile(read = nil)
    if !read && logfile_finalized?
      raise "Don't read a log aftr finalization"
    else
      @logfile ||= Tempfile.new
    end
  end

  private
  def set_ssh_output_hook(c)
    outbuf, errbuf = [], []
    check = ->(prefix,data,buf) do
      has_newline = data.include?("\n")
      lines = data.lines
      last = lines.pop
      if last[-1] == "\n"
        buf << last
      end
      if has_newline
        (buf+lines).join.each_line do |line|
          logfile.puts "#{prefix} #{line}"
        end
        buf.replace([])
      end
      if last[-1] != "\n"
        buf << last
      end
    end

    c.on_data do |_c, data|
      check.call "[OUT] ", data, outbuf
    end
    c.on_extended_data do |_c, _, data|
      check.call "[ERR] ", data, errbuf
    end
  end

end
