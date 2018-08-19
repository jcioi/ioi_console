class CreateMachines < ActiveRecord::Migration[5.2]
  def change
    create_table :machines do |t|
      t.string :mac
      t.integer :role

      t.timestamps
    end

    add_index :machines, :mac
  end
end
