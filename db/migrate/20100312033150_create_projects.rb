class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.string :identifier
      t.text :description
      t.integer :year
      t.integer :project_type
      t.date :valid_until
      t.text :forms
      t.integer :lock_version, :default => 0

      t.timestamps
    end

    add_index :projects, :identifier, :unique => true
  end

  def self.down
    remove_index :projects, :column => :identifier

    drop_table :projects
  end
end