class AddTestTypeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :test_type, :string
  end
end
