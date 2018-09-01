class ImportMachinesFromAllSwitchesJob < ApplicationJob
  def perform()
    Rails.application.config.x.ipam.switch_hosts.each do |host|
      FetchMachinesFromSwitchJob.perform_later(host)
    end
  end
end

