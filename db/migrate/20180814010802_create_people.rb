class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.string :login, null: false
      t.string :avatar_url
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :people, :login
    add_index :people, :role
  end
end
