class Person < ApplicationRecord
  belongs_to :team, required: false
  has_one :desk
  has_many :assignment_histories, class_name: 'DeskAssignmentHistory'
  has_many :passwords

  enum role: %i(staff contestant leader)

  before_validation do
    self.name = "#{first_name} #{last_name}" if self.name.blank? && first_name && last_name
  end

  def team=(value)
    team = case value
    when String
      Team.where(slug: value).first
    else
      value
    end
    association(:team).writer(team)
  end

  def display_name
    case
    when name
      name
    when first_name && last_name
      "#{first_name} #{last_name}"
    end
  end

  def password_attempt(value)
    self.passwords.in_use.any? { |_| _.attempt(value) }
  end
end
