class QuestionsTeachingUnits < ActiveRecord::Migration
  def up
    create_table :questions_teaching_units, id: false do |t|
      t.column :teaching_unit_id, :integer
      t.column :question_id, :integer
    end
    
    add_index :questions_teaching_units, :teaching_unit_id
    add_index :questions_teaching_units, :question_id
  end
  
  def down
    remove_index :questions_teaching_unit, column: [:teaching_unit_id, :question_id]
    
    drop_table :questions_teaching_units
  end
end
