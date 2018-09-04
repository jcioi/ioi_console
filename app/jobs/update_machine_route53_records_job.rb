class UpdateMachineRoute53RecordsJob < ApplicationJob
  def perform(machines = nil)
    if machines
      ActiveRecord::Base::Preloader.new.preload(machines, desk: :contestant)
      @machines = machines
    else
      @machines = Machine.includes(desk: :contestant).all
    end

    changes().each_slice(150) do |slice|
      slice.each do |c|
        rrset = c[:resource_record_set]
        Rails.logger.info "#{rrset[:name]} #{rrset[:type]} #{rrset[:resource_records][0][:value]}"
      end
      resp = route53.change_resource_record_sets(
        hosted_zone_id: hosted_zone,
        change_batch: {
          comment: "ioi_console UpdateMachineRoute53RecordsJob",
          changes: slice,
        }
      )
      change_id = resp.change_info.id
      Rails.logger.info "change_id: #{change_id}"
    end
  end

  private

  def route53
    @route53 ||= Aws::Route53::Client.new(region: 'us-east-1')
  end
  def changes
    @machines.flat_map do |machine|
      next unless machine.ip_address
      mac = machine.mac.gsub(/:/, '').downcase
      [
       {
          action: 'UPSERT',
          resource_record_set: {
            name: "#{mac}.#{domain}",
            type: 'A',
            ttl: 60,
            resource_records: [value: machine.ip_address],
          },
        },
        machine.desk && {
          action: 'UPSERT',
          resource_record_set: {
            name: "#{machine.desk.name.downcase}.#{domain}",
            type: 'CNAME',
            ttl: 60,
            resource_records: [value: "#{mac}.#{domain}"],
          },
        },
        machine.desk&.contestant && {
          action: 'UPSERT',
          resource_record_set: {
            name: "#{machine.desk.contestant.login.downcase}.#{domain}",
            type: 'CNAME',
            ttl: 60,
            resource_records: [value: "#{mac}.#{domain}"],
          },
        },
      ]
    end.compact
  end

  def hosted_zone
    Rails.application.config.x.ipam.route53_hosted_zone
  end

  def domain
    Rails.application.config.x.ipam.route53_domain
  end
end
