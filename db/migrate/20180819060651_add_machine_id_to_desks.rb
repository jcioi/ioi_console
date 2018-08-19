class AddMachineIdToDesks < ActiveRecord::Migration[5.2]
  def change
    add_reference :desks, :machine, foreign_key: true
  end
end
