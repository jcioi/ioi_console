class AddTeamIdToPeople < ActiveRecord::Migration[5.2]
  def change
    add_reference :people, :team, foreign_key: true
  end
end
