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
    redirect_to hailings_path, notice: 'Request has been dispatched to the contest staffs. Raise your hand if our staff is not coming.'
  end

  private

  def hailing_params
    params.require(:hailing).permit(:request, :details)
  end
end
