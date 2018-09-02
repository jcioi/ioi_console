require 'csv'

class Admin::PasswordsController < Admin::ApplicationController
  before_action :set_password_tier

  def index
    @role = params[:role].presence
    @passwords = Password.where(password_tier: @password_tier).includes(person: :team).order('people.login ASC')
    @passwords = @passwords.where(people: {role: @role}) if @role

    respond_to do |format|
      format.html { render :index }
      format.csv do
        csv = CSV.generate do |c|
          c << %w(team_slug team_name role login name password)
          @passwords.each do |password|
            c << [password.person&.team&.slug, password.person&.team&.name, password.person.role, password.person.login, password.person.display_name, password.plaintext_password]
          end
        end
        render plain: csv
      end
    end
  end

  def generate
    @people = Person.all
    @people = @people.where(role: params[:role]) if params[:role].present?
    @people = @people.where(login: params[:login]) if params[:login].present?
    @password_tier.generate!(people: @people, overwrite: params[:overwrite].present?)
    flash[:notice] = 'Password generated'
    redirect_to password_tier_passwords_path(@password_tier)
  end

  def print
    PrintPasswordsJob.perform_later(@password_tier, role: params[:role].presence)

    flash[:notice] = 'Queued password printing'
    redirect_to password_tier_passwords_path(@password_tier)
  end

  def export_to_cms
    unless @password_tier.contest&.taskable?
      flash[:error] = "No CMS Remote Task Target present to the contest"
      return redirect_to(password_tier_passwords_path(@password_tier))
    end

    ApplicationRecord.transaction do
      @remote_task = RemoteTask.create!(
        description: "Participation Export to CMS from: #{@password_tier.description}",
        kind: 'CmsBatchLoadParticipation',
        task_arguments: {'password_tier_id' => @password_tier.id},
        status: :creating
      )
      @remote_task.executions.create!(status: :created, target_kind: @password_tier.contest.cms_remote_task_driver, target: @password_tier.contest.cms_remote_task_target)
      @remote_task.status = :created
      @remote_task.save!
    end
    @remote_task.perform_later!

    return redirect_to(remote_task_executions_path(@remote_task), notice: 'Created remote task')
  end

  private

  def set_password_tier
    @password_tier = PasswordTier.find(params[:password_tier_id])
  end
end
