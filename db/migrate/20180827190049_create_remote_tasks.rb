class CreateRemoteTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_tasks do |t|
      t.string :kind, null: false
      t.jsonb :task_arguments, null: false
      t.integer :status, null: false
      t.string :description

      t.timestamps
    end
  end
end
