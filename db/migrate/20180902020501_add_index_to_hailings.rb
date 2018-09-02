class AddIndexToHailings < ActiveRecord::Migration[5.2]
  def change
    add_index :hailings, [:request_type, :contestant_id]
  end
end
