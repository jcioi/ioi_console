require 'ioiprint'

class PrintHailingJob < ApplicationJob
  queue_as :high if Rails.env.production?

  def perform(hailing)
    contestant = hailing.contestant

    Ioiprint.new.print_staff_call(
      message: hailing.request,
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

    hailing.update!(print_requested_at: Time.now)
  end
end
