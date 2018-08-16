class Person < ApplicationRecord
  enum role: %i(staff contestant leader)

  before_validation do
    self.name = "#{first_name} #{last_name}" if self.name.blank? && first_name && last_name
  end

  def display_name
    case
    when name
      name
    when first_name && last_name
      "#{first_name} #{last_name}"
    end
  end
end
