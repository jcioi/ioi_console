class RemoteTask::Drivers::Base
  def self.description_for(execution)
    ''
  end

  # @param scratch [#read]
  def initialize(execution:, script:, scratch: nil)
    @execution = execution
    @script = script
    @scratch = scratch
  end

  attr_reader :execution, :script, :scratch

  def execute!
    raise NotImplementedError
  end
end
