Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = false
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "ioi_console_#{Rails.env}"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  if ENV.fetch('IOI_SQS_REGION', ENV['AWS_REGION']) && ENV['IOI_SQS_QUEUE_PREFIX']
    config.active_job.queue_adapter = :shoryuken
    config.active_job.queue_name_prefix = ENV['IOI_SQS_QUEUE_PREFIX']
  else
    config.active_job.queue_adapter = :inline
  end

  config.x.remote_task.log_provider.aws_s3.region = ENV.fetch('IOI_S3_LOG_REGION')
  config.x.remote_task.log_provider.aws_s3.bucket = ENV.fetch('IOI_S3_LOG_BUCKET')
  config.x.remote_task.log_provider.aws_s3.prefix = ENV.fetch('IOI_S3_LOG_PREFIX')

  config.x.remote_task.driver.aws_ssm.polling = ENV['IOI_SSM_PROCESS_EVENTS'] != '1'
  config.x.remote_task.driver.aws_ssm.region = ENV.fetch('IOI_SSM_REGION')
  config.x.remote_task.driver.aws_ssm.log_s3_region = ENV.fetch('IOI_SSM_LOG_S3_REGION')
  config.x.remote_task.driver.aws_ssm.log_s3_bucket = ENV.fetch('IOI_SSM_LOG_S3_BUCKET')
  config.x.remote_task.driver.aws_ssm.log_s3_prefix = ENV.fetch('IOI_SSM_LOG_S3_PREFIX')
  config.x.remote_task.driver.aws_ssm.scratch_s3_region = ENV.fetch('IOI_SSM_SCRATCH_S3_REGION')
  config.x.remote_task.driver.aws_ssm.scratch_s3_bucket = ENV.fetch('IOI_SSM_SCRATCH_S3_BUCKET')
  config.x.remote_task.driver.aws_ssm.scratch_s3_prefix = ENV.fetch('IOI_SSM_SCRATCH_S3_PREFIX')

  config.x.remote_task.driver.ssh.user = ENV.fetch('IOI_SSH_USER', 'ioi')
  config.x.remote_task.driver.ssh.key_data = [ENV.fetch('IOI_SSH_KEY_BASE64').unpack('m*')[0]]
  config.x.remote_task.driver.ssh.log_s3_region = ENV.fetch('IOI_SSH_LOG_S3_REGION')
  config.x.remote_task.driver.ssh.log_s3_bucket = ENV.fetch('IOI_SSH_LOG_S3_BUCKET')
  config.x.remote_task.driver.ssh.log_s3_prefix = ENV.fetch('IOI_SSH_LOG_S3_PREFIX')

  config.x.ipam.leases_s3_region = ENV.fetch('IOI_IPAM_LEASES_S3_REGION')
  config.x.ipam.leases_s3_bucket = ENV.fetch('IOI_IPAM_LEASES_S3_BUCKET')
  config.x.ipam.leases_s3_key = ENV.fetch('IOI_IPAM_LEASES_S3_KEY')
  config.x.ipam.leases_target_ids = ENV.fetch('IOI_IPAM_LEASES_TARGET_IDS').split(?,).map(&:to_i)
  config.x.ipam.ssh_user = ENV.fetch('IOI_IPAM_SSH_USER')
  config.x.ipam.ssh_password = ENV.fetch('IOI_IPAM_SSH_PASSWORD')
  config.x.ipam.switch_hosts = ENV.fetch('IOI_IPAM_SWITCH_HOSTS').split(?,)

  config.x.ipam.route53_hosted_zone = ENV.fetch('IOI_IPAM_ROUTE53_ZONE')
  config.x.ipam.route53_domain = ENV.fetch('IOI_IPAM_ROUTE53_DOMAIN')

  config.x.prometheus_url = ENV.fetch('IOI_PROMETHEUS_URL')

  config.x.ioi2018_day2_special_announce_team = []
end


