class CreateSubtopics < ActiveRecord::Migration
  def change
    create_table :subtopics do |t|
      t.string :title
      t.references :topic

      t.timestamps null: false
    end
  end
end
