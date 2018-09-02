class Service::HailingsController < Service::ApplicationController
  def index
    @hailing = Hailing.new
    @hailings = Hailing.where(contestant: current_user).order(created_at: :desc).limit(20)
  end

  def create
    @hailing = Hailing.new(hailing_params)
    @hailing.contestant = current_user
    @hailing.save!
    PrintHailingJob.perform_later(@hailing)
    redirect_to hailings_path, notice: 'Your request has been sent. If any staff is not showing up for a while, raise your hand.'
  end

  private

  def hailing_params
    params.require(:hailing).permit(:request_type)
  end
end
