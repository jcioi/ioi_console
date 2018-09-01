require 'ioiprint'

class PrintPasswordsJob < ApplicationJob
  def perform(password_tier, role: nil)
    name = password_tier.contest&.name || password_tier.description  # TODO: consider password_tier.name?

    passwords = password_tier.passwords
      .includes(:person)
      .left_joins(person: :desk)
      .order(Arel.sql('desks.name ASC, people.login ASC'))
    passwords = passwords.where(people: {role: role}) if role.present?

    users = passwords.map do |password|
      {
        login: password.person.login,
        name: password.person.name,
        password: password.plaintext_password,
      }
    end

    slices = passwords.each_slice(50).to_a
    slices.each_with_index do |slice, idx|
      Ioiprint.new.print_passwords(
        title: "Password for #{name}",
        users: users,
      )
    end
  end
end
