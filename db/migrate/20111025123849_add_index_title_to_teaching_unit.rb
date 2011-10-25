class AddIndexTitleToTeachingUnit < ActiveRecord::Migration
  def change
    add_index :teaching_units, :title, :unique => true
  end
end
