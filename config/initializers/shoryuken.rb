module Shoryuken
  module Middleware
    module Server
      class RavenReporter
        def call(worker_instance, queue, sqs_msg, body)
          tags = { job: body['job_class'], queue: queue }
          context = { message: body }
          Raven.capture(tags: tags, extra: context) do
            yield
          end
        end
      end
    end
  end
end

if ENV.fetch('IOI_SQS_REGION', ENV['AWS_REGION']) && ENV['IOI_SQS_QUEUE_PREFIX']
  Shoryuken.active_job_queue_name_prefixing = true

  Shoryuken.configure_client do |config|
    config.sqs_client = Aws::SQS::Client.new(region: ENV.fetch('IOI_SQS_REGION', ENV['AWS_REGION']), log_level: :info)
  end
  Shoryuken.configure_server do |config|
    config.server_middleware do |chain|
      chain.add Shoryuken::Middleware::Server::RavenReporter
    end

    config.sqs_client = Aws::SQS::Client.new(region: ENV.fetch('IOI_SQS_REGION', ENV['AWS_REGION']), logger: Rails.logger)
    config.sqs_client_receive_message_opts = { wait_time_seconds: 20 }
  end
end
