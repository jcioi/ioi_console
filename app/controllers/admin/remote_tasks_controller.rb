class Admin::RemoteTasksController < Admin::ApplicationController
  before_action :set_remote_task, only: [:show, :edit, :update, :destroy]

  # GET /remote_tasks
  # GET /remote_tasks.json
  def index
    @remote_tasks = RemoteTask.all.order(id: :desc)
  end

  # GET /remote_tasks/new
  def new
    @remote_task = RemoteTask.new
  end

  def create
    @remote_task = RemoteTask.new(remote_task_params.except(:targets, :task_arguments).merge(status: :creating))

    begin
      targets = JSON.parse(remote_task_params[:targets])
    rescue JSON::ParserError, TypeError
    end
    begin
      arguments = JSON.parse(remote_task_params[:task_arguments])
    rescue JSON::ParserError, TypeError
    end

    unless targets && targets.is_a?(Array)
      flash[:error] = 'Failed to parse "targets" as JSON (it must be an array of maps)'
      return render :new
    end

    unless arguments && arguments.is_a?(Hash)
      flash[:error] = 'Failed to parse "arguments" as JSON (it must be a map)'
      return render :new
    end

    if targets.any? { |_| _['kind'].blank? }
      flash[:error] = 'Key "kind" must be present for all target'
      return render :new
    end

    @remote_task.task_arguments = arguments

    ApplicationRecord.transaction do
      unless @remote_task.save
        render :new
        return
      end
      targets.each do |target|
        kind = target.delete('kind')
        @remote_task.executions.create!(status: :created, target_kind: kind, target: target)
      end
      @remote_task.status = :created
      @remote_task.save!
    end
    @remote_task.perform_later!
    redirect_to remote_task_executions_path(@remote_task), notice: 'RemoteTask was successfully created.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_remote_task
      @remote_task = RemoteTask.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def remote_task_params
      @remote_task_params ||= params.require(:remote_task).permit(:description, :kind, :task_arguments, :targets)
    end
end
