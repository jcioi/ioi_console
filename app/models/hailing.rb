class Hailing < ApplicationRecord
  TYPE_TEXTS = {
    "restroom" => 'Restroom',
    "water" => 'Need an extra water bottle',
    "food_banana" => 'Need a banana',
    "food_chocolate" => 'Need a chocolate',
    "food_jelly" => "Need a jelly drink",
    "food_wafer" => "Need a wafer (halal)",
    "paper" => 'Need spare papers',
    "tech" => 'Technical problem',
    "handclar" => 'Handwritten clarification',
    "other" => 'Other',
    "get_out" => "Need to exit the contest venue",
  }
  HIDDEN_TYPES = %w(get_out)

  enum request_type: %i(
    other
    tech
    restroom
    paper
    handclar
    water
    food_banana
    food_chocolate
    food_jelly
    food_wafer
    get_out
  )

  def request
    TYPE_TEXTS.fetch(request_type) { request_type.to_s }
  end

  belongs_to :contestant, foreign_key: 'contestant_id', class_name: 'Person'
end
