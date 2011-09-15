class AddSociodemographicFormsToProjectInstances < ActiveRecord::Migration
  def self.up
    add_column :project_instances, :study_subjects, :integer
    add_column :project_instances, :degree_school, :text
    add_column :project_instances, :degree_university, :text
    add_column :project_instances, :study_subjects_choose, :text
  end

  def self.down
    remove_column :project_instances, :study_subjects
    remove_column :project_instances, :degree_school
    remove_column :project_instances, :degree_university
    remove_column :project_instances, :study_subjects_choose
  end
end
