class DeskAssignmentHistory < ApplicationRecord
  belongs_to :desk
  belongs_to :contestant, foreign_key: 'contestant_id', class_name: 'Person', required: false
end
