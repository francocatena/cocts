class AddGroupNameAndGroupTypeToProjectInstances < ActiveRecord::Migration
  def change
    add_column :project_instances, :group_type, :text
    add_column :project_instances, :group_name, :text
  end
end
