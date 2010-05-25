class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer :category
      t.integer :order
      t.text :clarification
      t.text :answer
      t.references :question
      t.integer :lock_version, :default => 0

      t.timestamps
    end

    add_index :answers, :question_id
  end

  def self.down
    remove_index :answers, :column => :question_id

    drop_table :answers
  end
end