class AddSpecialRequirementNoteToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :special_requirement_note, :text
  end
end
