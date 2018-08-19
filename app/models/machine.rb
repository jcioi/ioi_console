class Machine < ApplicationRecord
  has_one :desk
  has_many :assignment_histories, class_name: 'DeskAssignmentHistory'

  validates :mac, presence: true

  def mac=(value)
    write_attribute(:mac, normalize_mac(value))
  end

  def normalize_mac(value)
    value.gsub(/:/, '').downcase.chars.each_slice(2).map(&:join).join(':')
  end
end
