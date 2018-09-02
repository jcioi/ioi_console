class Person < ApplicationRecord
  belongs_to :team, required: false
  has_one :desk, dependent: :nullify, foreign_key: :contestant_id
  has_many :assignment_histories, class_name: 'DeskAssignmentHistory', dependent: :nullify, foreign_key: :contestant_id
  has_many :passwords, dependent: :destroy
  has_many :hailings, dependent: :nullify, foreign_key: :contestant_id

  enum role: %i(staff contestant leader)

  before_validation do
    self.name = "#{first_name} #{last_name}" if (self.name.blank? || self.first_name_changed? || self.last_name_changed?) && first_name && last_name
  end

  def first_and_last_name
    if first_name.present? && last_name.present?
      {first_name: first_name, last_name: last_name}
    elsif display_name.present?
      first_name, last_name = display_name.split(/\s+/, 2)
      last_name ||= '.'
      {first_name: first_name, last_name: last_name}
    else
      raise "Name invalid"
    end
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
    self.passwords.in_use.find { |_| _.attempt(value) }
  end
end
