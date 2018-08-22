class SessionsController < ApplicationController
  def new
    return_to = params[:return_to]
    uri = Addressable::URI.parse(return_to)
    if uri && uri.host.nil? && uri.scheme.nil? && uri.path.start_with?('/')
      session[:return_to] = params[:return_to]
    end
  end

  def create
    person = Person.where(login: params[:login]).first
    unless person
      flash[:error] = "No user found with login #{params[:login]}"
      return redirect_to(new_session_path)
    end

    matched_password = person.password_attempt(params[:password])
    unless matched_password
      flash[:error] = "Given password is incorrect or you're not allowed to log in at this moment"
      return redirect_to(new_session_path)
    end

    session[:person_id] = person.id
    session[:password_id] = matched_password.id
    return redirect_to(session.delete(:return_to) || '/')
  end

  def destroy
    session.delete(:person_id)
    session.delete(:password_id)
    redirect_to(new_session_path)
  end

  private
end
