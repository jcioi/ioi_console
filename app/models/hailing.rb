class Hailing < ApplicationRecord
  KINDS = [
    'Restroom',
    'Need an extra water bottle',
    'Spare sheet',
    'Technical problem',
    'Handwritten clarification',
    'Other',
  ]
  belongs_to :contestant, foreign_key: 'contestant_id', class_name: 'Person'
end
