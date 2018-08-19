class CreateContests < ActiveRecord::Migration[5.2]
  def change
    create_table :contests do |t|
      t.string :name
      t.string :cms_contest_id

      t.timestamps
    end
  end
end
