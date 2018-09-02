class Hailing < ApplicationRecord
  TYPE_TEXTS = {
    "restroom" => 'Restroom',
    "water" => 'Need an extra water bottle',
    "paper" => 'Need spare papers',
    "tech" => 'Technical problem',
    "handclar" => 'Handwritten clarification',
    "other" => 'Other',
  }
  enum request_type: %i(
    other
    tech
    restroom
    paper
    handclar
    water
  )

  def request
    TYPE_TEXTS.fetch(request_type) { request_type.to_s }
  end

  belongs_to :contestant, foreign_key: 'contestant_id', class_name: 'Person'
end
