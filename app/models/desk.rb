class Desk < ApplicationRecord
  belongs_to :floor
  belongs_to :contestant, class_name: 'Person', required: false
  has_many :assignment_histories, class_name: 'DeskAssignmentHistory'

  around_save :create_assignment_history

  def create_assignment_history
    create_history = self.contestant_id_changed?
    yield
    if create_history
      self.assignment_histories.create!(
        contestant_id: self.contestant_id,
      )
    end
  end

  def contestant=(value)
    floor = case value
    when String
      Person.where(login: value).first
    else
      value
    end
    association(:contestant).writer(floor)
  end

  def floor=(value)
    floor = case value
    when String
      Floor.find_or_create_by!(name: value)
    else
      value
    end
    association(:floor).writer(floor)
  end
end
