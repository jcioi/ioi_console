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
    @password_tier.generate!(people: @people, overwrite: params[:overwrite].present?)
    flash[:notice] = 'Password generated'
    redirect_to password_tier_passwords_path(@password_tier)
  end

  def print
    PrintPasswordsJob.perform_now(@password_tier, role: params[:role].presence)

    flash[:notice] = 'Queued password printing'
    redirect_to password_tier_passwords_path(@password_tier)
  end

  private

  def set_password_tier
    @password_tier = PasswordTier.find(params[:password_tier_id])
  end
end
