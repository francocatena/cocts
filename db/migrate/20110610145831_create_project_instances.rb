class CreateProjectInstances < ActiveRecord::Migration
  def self.up
    create_table :project_instances do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :name
      t.string :identifier
      t.text :description
      t.integer :year
      t.integer :project_type
      t.date :valid_until
      t.text :forms
      t.integer :age
      t.string :country
      t.string :genre
      t.string :degree
      t.text :profession_ocuppation
      t.text :profession_certification
      t.string :student_status
      t.string :teacher_status
      t.string :teacher_level
      t.references :project

      t.timestamps
    end
    
    add_index :project_instances, :project_id
  end

  def self.down
    remove_index :project_instances, column: :project_id
    
    drop_table :project_instances
  end
end
