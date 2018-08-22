class Floor < ApplicationRecord
  has_many :desks, dependent: :destroy
end
