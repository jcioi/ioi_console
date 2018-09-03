require 'csv'

class Admin::MachinesController < Admin::ApplicationController
  before_action :set_machine, only: [:show, :edit, :update, :destroy]

  skip_before_action :require_staff, only: %i(lookup prometheus_config)

  # GET /machines
  # GET /machines.json
  def index
    @machines = Machine.all.order(mac: :asc)
  end

  def lookup
    machine = Machine.where(ip_address: params[:ip]).first
    return render(status: :not_found, json: {}) unless machine
    contestant = machine&.desk&.contestant && {
      id: machine.desk.contestant.login,
      name: machine.desk.contestant.display_name,
      special_requirement_note: machine.desk.contestant.special_requirement_note.presence,
    }
    desk = machine&.desk && {
      id: machine.desk.name,
      zone: machine.desk.floor.name,
    }
    render(json: {
      machine: {mac: machine.mac, ip_address: machine.ip_address},
      contestant:  contestant,
      desk: desk,
    })
  end

  def prometheus_config
    configs = Machine.includes(desk: [:contestant, :floor]).all.map do |m|
      next unless m.desk && m.ip_address
      {
        targets: ["#{m.ip_address}:9090"],
        labels: {
          ioi_desk: m.desk ? "#{m.desk.floor.name}/#{m.desk.name}" : nil,
          ioi_contestant: m.desk.contestant ? m.desk.contestant.login : nil,
        },
      }
    end.compact
    render(json: [
      *configs,
    ])
  end

  # GET /machines/new
  def new
    @machine = Machine.new
  end

  # GET /machines/1/edit
  def edit
  end

  # POST /machines
  # POST /machines.json
  def create
    @machine = Machine.new(machine_params)

    respond_to do |format|
      if @machine.save
        format.html { redirect_to @machine, notice: 'Machine was successfully created.' }
        format.json { render :show, status: :created, location: @machine }
      else
        format.html { render :new }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /machines/1
  # PATCH/PUT /machines/1.json
  def update
    respond_to do |format|
      if @machine.update(machine_params)
        format.html { redirect_to @machine, notice: 'Machine was successfully updated.' }
        format.json { render :show, status: :ok, location: @machine }
      else
        format.html { render :edit }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /machines/1
  # DELETE /machines/1.json
  def destroy
    @machine.destroy
    respond_to do |format|
      format.html { redirect_to machines_url, notice: 'Machine was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /machines/import
  def import
    csv = CSV.new(params[:csv].to_io, headers: true)
    @errors = []
    csv.each do |row|
      machine = Machine.find_or_initialize_by(mac: row.fetch('mac'))
      [].each do |key|
        next unless row.key?(key.to_s)
        value = if row[key.to_s].present?
          row[key.to_s]
        else
          nil
        end
        machine.__send__(:"#{key}=", value)
      end
      unless machine.save
        @errors << machine
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_machine
      @machine = Machine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def machine_params
      params.require(:machine).permit(:mac)
    end
end
