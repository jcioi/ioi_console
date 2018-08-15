class AddIndexToTeams < ActiveRecord::Migration[5.2]
  def change
    add_index :teams, :slug
  end
end
