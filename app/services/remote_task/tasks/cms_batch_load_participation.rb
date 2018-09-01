class RemoteTask::Tasks::CmsBatchLoadParticipation < RemoteTask::Tasks::Base
  def initialize(execution)
    super(execution)
  end

  def script
    @script
  end

  def scratch
    @scratch
  end
end
