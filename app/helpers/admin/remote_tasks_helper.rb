module Admin::RemoteTasksHelper
  def status_label(task)
    case task.status
    when 'creating', 'created'
      'label label-default'
    when 'pending'
      'label label-warning'
    when 'running'
      'label label-primary'
    when 'cleaning'
      'label label-info'
    when 'succeeded', 'finished'
      'label label-success'
    when 'cancelled', 'failed'
      'label label-danger'
    end
  end
end
