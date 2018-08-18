class AddContestantIdToDesks < ActiveRecord::Migration[5.2]
  def change
    add_reference :desks, :contestant, foreign_key: {to_table: :people}
  end
end
