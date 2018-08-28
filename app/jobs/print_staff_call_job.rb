require 'ioiprint'

class PrintStaffCallJob < ApplicationJob
  queue_as :high if Rails.env.production?

  def perform(contestant:, message:)
    Ioiprint.new.print_staff_call(
      message: message,
      contestant: {
        id: contestant.login,
        name: contestant.name,
        special_requirement_note: contestant.special_requirement_note.presence,
      },
      desk: {
        id: contestant.desk&.name || 'N/A',
        map: nil,  # TODO!!!
      },
    )
  end
end
