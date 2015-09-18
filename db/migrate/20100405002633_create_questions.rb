class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :dimension
      t.string :code
      t.text :question
      t.integer :lock_version, default: 0

      t.timestamps null: false
    end

    add_index :questions, :dimension
    add_index :questions, :code, unique: true
  end

  def self.down
    remove_index :questions, column: :code
    remove_index :questions, column: :dimension

    drop_table :questions
  end
end
