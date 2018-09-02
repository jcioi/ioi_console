class AddCmsRemoteTaskTargetToContests < ActiveRecord::Migration[5.2]
  def change
    add_column :contests, :cms_remote_task_target, :jsonb
    add_column :contests, :cms_remote_task_driver, :string
  end
end
