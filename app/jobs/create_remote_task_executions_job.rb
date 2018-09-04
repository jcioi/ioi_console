class CreateRemoteTaskExecutionsJob < ApplicationJob
  def perform(remote_task, targets: [], machines: false)
    ApplicationRecord.transaction do
      remote_task.lock!
      unless remote_task.creating?
        Rails.logger.warn "RemoteTask #{remote_task.id} is not in creating state, aborting (#{remote_task.status})"
        return
      end
      remote_task.update!(status: :preparing)
      remote_task.lock!(false)

      targets.each do |target|
        kind = target.delete('kind') || target.delete(:kind)
        remote_task.executions.create!(status: :created, target_kind: kind, target: target)
      end

      if machines
        Desk.includes(:machine).all.each do |desk|
          next unless desk.machine
          machine = desk.machine
          next unless machine.ip_address
          remote_task.executions.create!(
            status: :created,
            target_kind: 'Ssh',
            description: "SSH: #{machine.ip_address} #{desk.name} #{desk.contestant&.login}",
            target: {hostname: machine.ip_address}
          )
        end
      end

      remote_task.status = :created
      remote_task.save!
    end

    remote_task.perform_later!
  end
end
