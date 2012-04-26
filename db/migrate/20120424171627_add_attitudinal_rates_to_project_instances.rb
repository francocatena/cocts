class AddAttitudinalRatesToProjectInstances < ActiveRecord::Migration
  def change
    add_column :project_instances, :plausible_attitude_index, :string
    add_column :project_instances, :adecuate_attitude_index, :string
    add_column :project_instances, :naive_attitude_index, :string    
  end
end
