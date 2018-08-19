class CreatePasswords < ActiveRecord::Migration[5.2]
  def change
    create_table :password_tiers do |t|
      t.string :description
      t.datetime :not_before
      t.datetime :not_after
    end

    create_table :passwords do |t|
      t.references :person, foreign_key: true
      t.references :password_tier, foreign_key: true
      t.string :plaintext_password

      t.timestamps
    end

    add_index :passwords, [:person_id, :password_tier_id]
  end
end
