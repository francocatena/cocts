class AddCodeToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :code, :integer
  end
end
