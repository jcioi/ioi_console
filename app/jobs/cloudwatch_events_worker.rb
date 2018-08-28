class CloudwatchEventsWorker
  include Shoryuken::Worker
  shoryuken_options queue: "#{ENV['IOI_SQS_QUEUE_PREFIX']}_cloudwatchevents", auto_delete: true, body_parser: :json, batch: false

  def perform(sqs_msg, message)
    return if message['detail-type'] != 'EC2 Command Status-change Notification'
    command_id = message.dig('detail', 'command-id')
    return unless command_id

    execution = RemoteTaskExecution.where(target_kind: 'AwsSsm', external_id: command_id).first
    unless execution
      Rails.logger.warn "Unknown command_id=#{command_id}, skipping"
      return
    end

    Rails.logger.info "Event: #{message.inspect}"
    if RemoteTask::Drivers::AwsSsm.poll?
      Rails.logger.warn "Event received for known command_id, but ignoring because we're polling"
      return
    end
    execution.driver(scratch: nil, script: nil).execute!
    execution.handle_result() if execution.finished?
  end
end
