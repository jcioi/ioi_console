class Team < ApplicationRecord
  has_many :people, as: :members
end
