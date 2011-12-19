class AddNewSociodemographicFormsToProjectInstances < ActiveRecord::Migration
  def change
    add_column :project_instances, :educational_center_city, :text
    add_column :project_instances, :educational_center_name, :text
    add_column :project_instances, :study_subjects_different, :text
  end
end
