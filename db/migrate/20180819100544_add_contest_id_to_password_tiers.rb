class AddContestIdToPasswordTiers < ActiveRecord::Migration[5.2]
  def change
    add_reference :password_tiers, :contest, foreign_key: true
  end
end
