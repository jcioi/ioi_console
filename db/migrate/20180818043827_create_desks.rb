class CreateDesks < ActiveRecord::Migration[5.2]
  def change
    create_table :desks do |t|
      t.string :name
      t.references :floor, foreign_key: true

      t.timestamps
    end

    add_index :desks, :name
  end
end
