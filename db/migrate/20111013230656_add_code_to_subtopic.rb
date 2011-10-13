class AddCodeToSubtopic < ActiveRecord::Migration
  def change
    add_column :subtopics, :code, :integer
  end
end
