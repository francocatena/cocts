class CreateAnswerInstances < ActiveRecord::Migration
  def self.up
    create_table :answer_instances do |t|
      t.references :question_instance
      t.references :answer
      t.text :answer_text
      t.integer :order
      t.integer :answer_category
      t.string :valuation, limit: 1

      t.timestamps
    end
    add_index :answer_instances, :question_instance_id
    add_index :answer_instances, :answer_id
  end

  def self.down
    remove_index :answer_instances, column: :question_instance_id
    remove_index :answer_instances, column: :answer_id
    drop_table :answer_instances
  end
end
