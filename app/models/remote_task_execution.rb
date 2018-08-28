class RemoteTaskExecution < ApplicationRecord
  belongs_to :task, class_name: 'RemoteTask', foreign_key: 'remote_task_id'

  enum status: %i(creating created pending running cleaning succeeded cancelled failed)

  validates :target_kind, presence: true

  before_validation do
    set_description_using_driver unless self.description.present?
    self.state ||= {}
    self.target ||= {}
  end

  def starting?
    created?
  end

  def finishing?
    finished? || cleaning?
  end

  def finished?
    %w(succeeded cancelled failed).include?(status)
  end

  def task_object
    @task_object = self.task.task_class.new(self, **task.task_arguments.symbolize_keys)
  end

  def prepare
    task_object.prepare()
  end

  def driver_args
    task_object.driver_args()
  end

  def handle_result
    task_object.handle_result()
  end

  def invalid_for_execution?
    driver(**driver_args)
    nil
  rescue KeyError, ArgumentError => e
    e
  end

  def execute!()
    prepare()
    driver(**driver_args).tap{ |_| p _ }.execute!
    handle_result()
  end

  def set_description_using_driver
    self.description = driver_class.description_for(self)
  end

  def driver_class
    RemoteTask::Drivers.const_get(target_kind)
  end

  def driver(scratch: nil, script: nil)
    driver_class.new(execution: self, script: script, scratch: scratch)
  end

  def log_provider
    if log_kind && log
      RemoteTask::LogProviders.const_get(log_kind).new(**log.symbolize_keys)
    end
  end
end
