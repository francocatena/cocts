class RenameLastNameToProjectInstances < ActiveRecord::Migration
  def change
    rename_column :project_instances, :last_name, :professor_name
  end
end
