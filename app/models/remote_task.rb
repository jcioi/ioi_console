class RemoteTask < ApplicationRecord
  has_many :executions, class_name: 'RemoteTaskExecution', foreign_key: 'remote_task_id'

  enum status: %i(creating created pending running cleaning cancelled finished preparing)

  validates :kind, presence: true
  validates :task_arguments, presence: true
  validates :status, presence: true

  validate :valid_task_arguments

  def perform_later!
    self.update!(status: :pending)
    self.executions.reload.each do |execution|
      ExecuteRemoteTaskExecutionJob.perform_later(execution)
    end
  end

  def update_status
    return self if self.creating? || self.created?

    statuses = self.executions.distinct.order(status: :asc).pluck(:status)
    case
    when statuses == %w(pending), statuses == %(created pending)
      self.status = :pending
    when (statuses - %w(succeeded cancelled failed)).empty?
      self.status = :finished
    when (statuses - %w(cleaning succeeded cancelled failed)).empty?
      self.status = :cleaning
    else
      self.status = :running
    end
    self
  end

  def task_class
    RemoteTask::Tasks.const_get(kind)
  end

  private

  def valid_task_arguments
    if kind && (self.task_class() rescue nil).nil?
      errors.add(:kind, "doesn't exist")
      return
    end
  end
end
