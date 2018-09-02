class ExecuteRemoteTaskExecutionJob < ApplicationJob
  def perform(execution, force: false)
    Rails.logger.info "Executing #{execution.description} (#{execution.id}, task=#{execution.task.description}(#{execution.task.id}))"
    Raven.tags_context(remote_task_execution_id: execution.id, remote_task_id: execution.task.id)

    ApplicationRecord.transaction do
      return if !force && !execution.created?
      execution.with_lock do
        return if !force && !execution.created?
        execution.update!(status: :pending)
      end

      begin
        e = execution.invalid_for_execution?
        if e
          Rails.logger.error "Execution(#{execution.id}) was invalid for execution: #{e.inspect}"
          execution.update!(status: :failed)
          Raven.capture_exception(e)
          raise if Rails.env.development?
          return
        end
      rescue => e
        execution.update!(status: :failed)
        Rails.logger.error "Execution(#{execution.id}) was invalid for execution: #{e.inspect}"
        Raven.capture_exception(e)
        raise if Rails.env.development?
        return
      end
    end

    Rails.logger.error "Execution(#{execution.id}) is starting..."
    begin
      execution.execute!
    rescue => e
      execution.status = :failed
      execution.state['_exception'] = e.inspect
      execution.state['_exception_full'] = e.full_message
      Rails.logger.error "Execution(#{execution.id}) has been failed with exception: #{e.full_message}"
      Raven.capture_exception(e)
    end

    execution.save!
    Rails.logger.error "Execution(#{execution.id}) is finished: status=#{execution.status}"
  ensure
    begin
      execution.task.update_status.save!
    rescue => e
      Raven.capture_exception(e)
    end
  end
end
