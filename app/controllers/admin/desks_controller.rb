require 'csv'

class Admin::DesksController < Admin::ApplicationController
  before_action :set_desk, only: [:show, :edit, :update, :destroy]

  # GET /desks
  # GET /desks.json
  def index
    @desks = Desk.all.includes(:floor).includes(:contestant).includes(:machine).order(name: :asc)
    @machine_probe = MachineProber.new.statuses
  end

  # GET /desks/new
  def new
    @desk = Desk.new
  end

  # GET /desks/1/edit
  def edit
  end

  # POST /desks
  # POST /desks.json
  def create
    @desk = Desk.new(desk_params)

    respond_to do |format|
      if @desk.save
        format.html { redirect_to @desk, notice: 'Desk was successfully created.' }
        format.json { render :show, status: :created, location: @desk }
      else
        format.html { render :new }
        format.json { render json: @desk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /desks/1
  # PATCH/PUT /desks/1.json
  def update
    respond_to do |format|
      if @desk.update(desk_params)
        format.html { redirect_to @desk, notice: 'Desk was successfully updated.' }
        format.json { render :show, status: :ok, location: @desk }
      else
        format.html { render :edit }
        format.json { render json: @desk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /desks/1
  # DELETE /desks/1.json
  def destroy
    @desk.destroy
    respond_to do |format|
      format.html { redirect_to desks_url, notice: 'Desk was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /desks/import
  def import
    csv = CSV.new(params[:csv].to_io, headers: true)
    @errors = []
    csv.each do |row|
      desk = Desk.find_or_initialize_by(name: row.fetch('name'))
      %w(floor contestant machine switch_host switch_interface).each do |key|
        next unless row.key?(key.to_s)
        value = if row[key.to_s].present?
          row[key.to_s]
        else
          nil
        end
        desk.__send__(:"#{key}=", value)
      end
      unless desk.save
        @errors << desk
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_desk
      @desk = Desk.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def desk_params
      params.require(:desk).permit(:slug, :name, :contestant)
    end
end
