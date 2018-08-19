require 'csv'

class Admin::PasswordTiersController < Admin::ApplicationController
  before_action :set_password_tier, only: [:show, :edit, :update, :destroy]

  # GET /password_tiers
  # GET /password_tiers.json
  def index
    @password_tiers = PasswordTier.all.includes(:contest)
  end

  # GET /password_tiers/new
  def new
    @password_tier = PasswordTier.new
  end

  # GET /password_tiers/1/edit
  def edit
  end

  # POST /password_tiers
  # POST /password_tiers.json
  def create
    @password_tier = PasswordTier.new(password_tier_params)

    respond_to do |format|
      if @password_tier.save
        format.html { redirect_to @password_tier, notice: 'PasswordTier was successfully created.' }
        format.json { render :show, status: :created, location: @password_tier }
      else
        format.html { render :new }
        format.json { render json: @password_tier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /password_tiers/1
  # PATCH/PUT /password_tiers/1.json
  def update
    respond_to do |format|
      if @password_tier.update(password_tier_params)
        format.html { redirect_to @password_tier, notice: 'PasswordTier was successfully updated.' }
        format.json { render :show, status: :ok, location: @password_tier }
      else
        format.html { render :edit }
        format.json { render json: @password_tier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /password_tiers/1
  # DELETE /password_tiers/1.json
  def destroy
    @password_tier.destroy
    respond_to do |format|
      format.html { redirect_to password_tiers_url, notice: 'PasswordTier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_password_tier
      @password_tier = PasswordTier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def password_tier_params
      params.require(:password_tier).permit(:description, :not_before, :not_after, :contest_id)
    end
end
