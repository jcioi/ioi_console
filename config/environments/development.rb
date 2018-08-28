Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker unless ENV['BUILD']

  # *.lo.example.org
  config.action_dispatch.tld_length = 2

  config.active_job.queue_adapter = :async

  config.x.remote_task.log_provider.aws_s3.region = ENV.fetch('IOI_S3_LOG_REGION', 'ap-northeast-1')
  config.x.remote_task.log_provider.aws_s3.bucket = ENV.fetch('IOI_S3_LOG_BUCKET', 'ioi18-misc-internal')
  config.x.remote_task.log_provider.aws_s3.prefix = ENV.fetch('IOI_S3_LOG_PREFIX', 'console-dev/remote-task/log/')

  config.x.remote_task.driver.aws_ssm.region = ENV.fetch('IOI_SSM_REGION', 'ap-northeast-1')
  config.x.remote_task.driver.aws_ssm.log_s3_region = ENV.fetch('IOI_SSM_LOG_S3_REGION', 'ap-northeast-1')
  config.x.remote_task.driver.aws_ssm.log_s3_bucket = ENV.fetch('IOI_SSM_LOG_S3_BUCKET', 'ioi18-misc-internal')
  config.x.remote_task.driver.aws_ssm.log_s3_prefix = ENV.fetch('IOI_SSM_LOG_S3_PREFIX', 'console-dev/remote-task/ssm-log/')
  config.x.remote_task.driver.aws_ssm.scratch_s3_region = ENV.fetch('IOI_SSM_SCRATCH_S3_REGION', 'ap-northeast-1')
  config.x.remote_task.driver.aws_ssm.scratch_s3_bucket = ENV.fetch('IOI_SSM_SCRATCH_S3_BUCKET', 'ioi18-misc-internal')
  config.x.remote_task.driver.aws_ssm.scratch_s3_prefix = ENV.fetch('IOI_SSM_SCRATCH_S3_PREFIX', 'console-dev/remote-task/ssm-scratch/')
end
