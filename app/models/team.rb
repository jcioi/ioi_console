class Team < ApplicationRecord
  has_many :people, as: :members, dependent: :nullify

  def ioi2018_day2_special_announce_team?
    Rails.application.config.x.ioi2018_day2_special_announce_team.include?(self.slug)
  end
end
