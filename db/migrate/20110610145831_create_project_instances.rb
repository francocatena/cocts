class CreateProjectInstances < ActiveRecord::Migration
  def self.up
    create_table :project_instances do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.references :project

      t.timestamps
    end
    
    add_index :project_instances, :project_id
  end

  def self.down
    remove_index :project_instances, :column => :project_id
    
    drop_table :project_instances
  end
end
