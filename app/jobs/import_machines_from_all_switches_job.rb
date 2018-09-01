class ImportMachinesFromAllSwitchesJob < ApplicationJob
  def perform(now: false)
    Rails.application.config.x.ipam.switch_hosts.each do |host|
      if now
        FetchMachinesFromSwitchJob.perform_now(host)
      else
        FetchMachinesFromSwitchJob.perform_later(host)
      end
    end
  end
end

