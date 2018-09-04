require 'csv'

class ImportDhcpLeasesJob < ApplicationJob
  def perform()
    leases = {}
    leases_file.each do |row|
      next unless target_ids.include?(row['subnet_id'].to_i)
      leases[row.fetch('hwaddr')] = row.fetch('address')
    end
    changed_machines = []
    ApplicationRecord.transaction do
      Machine.where(mac: leases.keys).each do |machine|
        machine.ip_address = leases.fetch(machine.mac)
        changed_machines.push(machine) if machine.machine_id_changed?
        machine.save!
      end
    end

    UpdateMachineRoute53RecordsJob.perform_later(changed_machines)
  end

  private

  def target_ids
    Rails.application.config.x.ipam.leases_target_ids
  end

  def s3
    @s3 ||= Aws::S3::Client.new(region: Rails.application.config.x.ipam.leases_s3_region)
  end

  def leases_file
    @leases_file ||= Tempfile.new.yield_self do |io|
      s3.get_object(
        bucket: Rails.application.config.x.ipam.leases_s3_bucket,
        key: Rails.application.config.x.ipam.leases_s3_key,
        response_target: io,
      )
      io.rewind
      CSV.open(io, headers: true)
    end
  end
end
