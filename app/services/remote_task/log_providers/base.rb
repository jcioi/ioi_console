require 'tempfile'

class RemoteTask::LogProviders::Base
  class NotWritable < StandardError; end
  class NotPersisted < StandardError; end
  class AlreadyPersisted < NotWritable; end

  def self.for_execution(execution)
    raise NotImplementedError
  end

  # @return [IO]
  def get
    raise NotImplementedError
  end

  # @return [String, nil]
  def url
    nil
  end

  def save!
    raise NotImplementedError
  end

  def to_h
    raise NotImplementedError
  end

  def exist?
    raise NotImplementedError
  end

  def writable?
    !exist?
  end

  def persisted?
    exist?
  end

  def buffer
    raise NotWritable unless writable?
    @buffer ||= Tempfile.new
  end
end

