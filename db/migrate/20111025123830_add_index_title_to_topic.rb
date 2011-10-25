class AddIndexTitleToTopic < ActiveRecord::Migration
  def change
    add_index :topics, :title, :unique => true
  end
end
