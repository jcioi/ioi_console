class AddIpamToMachines < ActiveRecord::Migration[5.2]
  def change
    add_column :desks, :switch_host, :string
    add_column :desks, :switch_interface, :string
    add_index :desks, [:switch_host, :switch_interface], unique: true

    add_column :machines, :ip_address, :string
  end
end
