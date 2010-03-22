class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.integer :year
      t.integer :project_type
      t.date :valid_until
      t.integer :lock_version, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end