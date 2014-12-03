class CreateProjectsQuestions < ActiveRecord::Migration
  def self.up
    create_table :projects_questions, id: false do |t|
      t.integer :project_id
      t.integer :question_id
    end

    add_index :projects_questions, [:project_id, :question_id]
  end

  def self.down
    remove_index :projects_questions, column: [:project_id, :question_id]

    drop_table :projects_questions
  end
end