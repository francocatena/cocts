class CreateQuestionInstances < ActiveRecord::Migration
  def self.up
    create_table :question_instances do |t|
      t.references :project_instance
      t.references :question
      t.text :question_text
      t.timestamps
    end
    add_index :question_instances, :project_instance_id
    add_index :question_instances, :question_id
  end

  def self.down
    remove_index :question_instances, column: :project_instance_id
    remove_index :question_instances, column: :question_id
    drop_table :question_instances
  end
end
