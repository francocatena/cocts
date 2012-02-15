class AddGroupNameAndGroupTypeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :group_name, :text
    add_column :projects, :group_type, :text
  end
end
