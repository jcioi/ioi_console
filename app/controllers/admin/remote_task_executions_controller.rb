require 'csv'

class Admin::RemoteTaskExecutionsController < Admin::ApplicationController
  before_action :set_remote_task

  def index
    @role = params[:role].presence
    @remote_task_executions = RemoteTaskExecution.where(task: @remote_task).order(id: :asc)

    respond_to do |format|
      format.html { render :index }
    end
  end

  def show
    @execution = RemoteTaskExecution.find(params[:id])
  end

  private

  def set_remote_task
    @remote_task = RemoteTask.find(params[:remote_task_id])
  end
end
