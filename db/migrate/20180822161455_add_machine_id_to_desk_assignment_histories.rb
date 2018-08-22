class AddMachineIdToDeskAssignmentHistories < ActiveRecord::Migration[5.2]
  def change
    add_reference :desk_assignment_histories, :machine, foreign_key: true
  end
end
