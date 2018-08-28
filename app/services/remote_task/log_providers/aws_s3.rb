require 'aws-sdk-s3'

class RemoteTask::LogProviders::AwsS3 < RemoteTask::LogProviders::Base
  def self.make_s3_client(region: nil)
    Aws::S3::Client.new(
      region: region || Rails.application.config.x.remote_task.log_provider.aws_s3.region,
      logger: Rails.logger,
    )
  end
  class_attribute :s3, default: make_s3_client()

  def self.for_execution(execution)
    self.new(
      bucket: Rails.application.config.x.remote_task.log_provider.aws_s3.bucket,
      key: "#{Rails.application.config.x.remote_task.log_provider.aws_s3.prefix}#{execution.remote_task_id}_#{execution.id}",
    )
  end

  def initialize(key:, bucket:, region: nil)
    @key = key
    @bucket = bucket
    self.s3 = self.class.make_s3_client(region: region) if self.class.s3.config.region != region
  end

  attr_reader :key
  attr_reader :bucket

  # @return [IO]
  def get
    s3.get_object(
      bucket: bucket,
      key: key
    ).body
  rescue Aws::S3::Errors::AccessDenied, Aws::S3::Errors::NotFound, Aws::S3::Errors::NoSuchKey
    @existence = false
    raise NotPersisted
  end

  # @return [String]
  def url
    raise NotPersisted unless persisted?
    Aws::S3::Presigner.new(client: s3).presign(:get_object, bucket: bucket, key: key, expires_in: 600)
  end

  def save!
    raise AlreadyPersisted if exist?
    buffer.rewind
    s3.put_object(
      bucket: bucket,
      key: key,
      body: buffer,
    )
    @existence = true
  end

  def to_h
    {
      bucket: bucket,
      key: key,
      region: s3.config.region,
    }
  end

  def exist?
    unless defined? @existence
      begin
        s3.head_object(bucket: bucket, key: key)
        @existence = true
      rescue Aws::S3::Errors::AccessDenied, Aws::S3::Errors::NotFound, Aws::S3::Errors::NoSuchKey
        @existence = false
      end
    end
    @existence
  end
end

