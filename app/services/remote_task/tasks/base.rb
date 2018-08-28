class RemoteTask::Tasks::Base
  def initialize(execution)
    @execution = execution
  end

  attr_reader :execution

  def prepare
  end

  def driver_args
    {script: script, scratch: scratch}
  end

  def handle_result
  end
end
