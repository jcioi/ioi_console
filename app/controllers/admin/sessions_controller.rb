require 'open-uri'
require 'addressable/uri'
require 'octokit'

class Admin::SessionsController < ApplicationController
  STAFF_GH_TEAMS = ENV.fetch('GITHUB_TEAMS').split(/,\s*|\s+/).map(&:downcase)

  def new
    if params[:proceed]
      return_to = params[:return_to]
      uri = Addressable::URI.parse(return_to)
      if uri && uri.host.nil? && uri.scheme.nil? && uri.path.start_with?('/')
        session[:return_to] = params[:return_to]
      end
      return redirect_to("/auth/github")
    end

  end

  def create
    auth = request.env['omniauth.auth']
    case auth[:provider]
    when 'github'
      case
      when ENV['GITHUB_ACCESS_TOKEN']
        unless staff_member?(auth.fetch('info').fetch('nickname'))
          return render(status: 403, text: "Forbidden (You have to be in any of these teams: #{STAFF_GH_TEAMS.join(', ')}")
        end
      when Rails.env.production?
        raise "$GITHUB_ACCESS_TOKEN is missing"
      end

      person = Person.create_with(
        name: auth.fetch('info').fetch('name'),
        avatar_url: auth.fetch('info').fetch('image'),
      ).find_or_create_by!(
        login: auth.fetch('info').fetch('nickname'),
      )
    else
      raise "Unsupported provider: #{auth[:provider]}"
    end

    session[:person_id] = person.id
    return redirect_to(session.delete(:return_to) || '/')
  end

  def destroy
    session.delete(:person_id)
    redirect_to(new_admin_session_path)
  end

  private

  def staff_member?(login)
    octo = Octokit::Client.new(
      access_token: ENV.fetch('GITHUB_ACCESS_TOKEN'),
      per_page: 100,
    )

    STAFF_GH_TEAMS.each do |team_id|
      if octo.team_membership(team_id, login)
        return true
      end
    rescue Octokit::NotFound
    end

    return false
  end
end
