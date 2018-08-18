class CreateDeskAssignmentHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :desk_assignment_histories do |t|
      t.references :desk, foreign_key: true
      t.references :contestant, foreign_key: {to_table: :people}

      t.timestamps
    end
  end
end
