class RemoteTask::Tasks::Script < RemoteTask::Tasks::Base
  def initialize(execution, script:, scratch: nil)
    super(execution)
    @script = script
    @scratch = case scratch
               when String
                 StringIO.new(scratch, 'r')
               when IO
                 scratch
               when nil
                 nil
               else
                 scratch.to_io
               end
  end

  def script
    @script
  end

  def scratch
    @scratch
  end
end
