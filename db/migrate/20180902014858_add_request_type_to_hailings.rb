class AddRequestTypeToHailings < ActiveRecord::Migration[5.2]
  def change
    add_column :hailings, :request_type, :integer
    remove_column :hailings, :details
    remove_column :hailings, :request
  end
end
