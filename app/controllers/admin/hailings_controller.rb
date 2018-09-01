class Admin::HailingsController < Admin::ApplicationController
  # GET /desks
  # GET /desks.json
  def index
    @hailings = Hailing.all.includes(contestant: :desk).order(id: :desc).limit(100)
  end
end
