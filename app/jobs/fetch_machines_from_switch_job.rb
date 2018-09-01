class FetchMachinesFromSwitchJob < ApplicationJob
  def perform(switch_host)
    @switch_host = switch_host
    table = ssh do |s|
      s.exec!("show mac address-table")
    end

    interfaces = {}

    use = 0
    table.each_line do |line|
      if use < 2
        use += 1 if line.chomp.match?(/^[\- ]+$/)
        next
      end
      record = line.chomp.strip.split(/\s+/)
      break if record[0] == 'Total'
      mac = record[1].downcase.gsub(/[^a-f0-9]/, '').chars.each_slice(2).map(&:join).join(':')
      interfaces[record[-1]] = mac
    end

    ApplicationRecord.transaction do
      machines = Machine.where(mac: interfaces.values).map{ |_| [_.mac, _] }.to_h
      pp interfaces.keys
      Desk.where(switch_host: @switch_host, switch_interface: interfaces.keys).each do |desk|
        mac = interfaces[desk.switch_interface]
        machine = machines[mac] || Machine.create!(mac: mac)
        desk.machine = machine
        if desk.machine_id_changed?
          Rails.logger.info "Desk #{desk.name} (#{desk.id}) => Machine #{machine.mac} (#{machine.id})"
        end
        desk.save!
      end
    end
  end

  private

  def ssh(&block)
    Net::SSH.start(@switch_host, Rails.application.config.x.ipam.ssh_user, password: Rails.application.config.x.ipam.ssh_password, &block)
  end
end

