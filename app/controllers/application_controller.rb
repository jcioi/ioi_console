class ApplicationController < ActionController::Base
  helper_method def current_user
    return @current_user if defined? @current_user
    if session[:person_id]
      @current_user = Person.find_by(id: session[:person_id])
      password = Password.find_by(id: session[:password_id]) if session[:password_id]
      if !@current_user || (session[:password_id] ? !password : false)
        session.delete(:person_id)
        session.delete(:password_id)
      end
    end
    @current_user
  end

  def require_staff
    return redirect_to(new_admin_session_path(return_to: url_for(params.to_unsafe_h.merge(only_path: true)))) unless current_user
    return render(status: 403, text: 'Forbidden: You need to be a staff') unless current_user.staff?
  end

  def require_contestant
    return redirect_to(new_session_path) unless current_user
    return render(status: 403, text: 'Forbidden: You need to be a contestant') unless current_user.contestant?
  end

  def require_leader
    return redirect_to(new_session_path) unless current_user
    return render(status: 403, text: 'Forbidden: You need to be a leader') unless current_user.leader?
  end
end
