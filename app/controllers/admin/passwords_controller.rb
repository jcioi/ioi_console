class Admin::PasswordsController < Admin::ApplicationController
  before_action :set_password_tier

  def index
    @passwords = Password.where(password_tier: @password_tier).joins(:person).order('people.login ASC')
    @passwords = @passwords.where(person: {role: params[:role]}) if params[:role].present?
  end

  def generate
    @people = Person.all
    @people = @people.where(role: params[:role]) if params[:role].present?
    @password_tier.generate!(people: @people, overwrite: params[:overwrite].present?)
    flash[:notice] = 'Password generated'
    redirect_to password_tier_passwords_path(@password_tier)
  end

  def set_password_tier
    @password_tier = PasswordTier.find(params[:password_tier_id])
  end
end
