module ApplicationHelper
  def sidebar_active_class(c)
    controller_path == c ? %w(active) : []
  end

end
