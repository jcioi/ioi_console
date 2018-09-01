class Hailing < ApplicationRecord
  KINDS = [
    'Restroom',
    'Spare sheet',
    'Technical problem',
    'Handwritten clarification',
    'Other',
  ]
  belongs_to :contestant, foreign_key: 'contestant_id', class_name: 'Person'
end
