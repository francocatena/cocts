class CreateProjectsTeachingUnits < ActiveRecord::Migration
  def up
    create_table :projects_teaching_units, :id => false do |t|
      t.column :teaching_unit_id, :integer
      t.column :project_id, :integer
    end
    
    add_index :projects_teaching_units, :teaching_unit_id
    add_index :projects_teaching_units, :project_id
  end
  
  def down
    remove_index :projects_teaching_unit, :column => [:teaching_unit_id, :project_id]
    
    drop_table :projects_teaching_units
  end
end
