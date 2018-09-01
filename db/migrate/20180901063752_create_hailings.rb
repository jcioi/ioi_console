class CreateHailings < ActiveRecord::Migration[5.2]
  def change
    create_table :hailings do |t|
      t.references :contestant, foreign_key: {to_table: :people}
      t.string :request
      t.text :details

      t.timestamps
    end

    add_index :hailings, [:contestant_id, :created_at]
  end
end
