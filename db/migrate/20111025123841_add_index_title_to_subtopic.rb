class AddIndexTitleToSubtopic < ActiveRecord::Migration
  def change
    add_index :subtopics, :title, :unique => true
  end
end
