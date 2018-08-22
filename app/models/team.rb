class Team < ApplicationRecord
  has_many :people, as: :members, dependent: :nullify
end
