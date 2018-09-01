class AddPrintedAtToHailings < ActiveRecord::Migration[5.2]
  def change
    add_column :hailings, :print_requested_at, :datetime
  end
end
