class CreateRemoteTaskExecutions < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_task_executions do |t|
      t.references :remote_task, foreign_key: true, null: false
      t.integer :status, null: false
      t.string :description, null: true
      t.jsonb :state, null: false
      t.string :target_kind, null: false
      t.jsonb :target, null: false
      t.string :external_id
      t.string :log_kind
      t.jsonb :log

      t.timestamps
    end

    add_index :remote_task_executions, [:target_kind, :external_id]
  end
end
