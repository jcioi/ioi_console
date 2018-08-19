class PasswordUniqueness < ActiveRecord::Migration[5.2]
  def change
    remove_index :passwords, [:person_id, :password_tier_id]
    add_index :passwords, [:person_id, :password_tier_id], unique: true
  end
end
