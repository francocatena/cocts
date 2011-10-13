class CreateTeachingUnits < ActiveRecord::Migration
  def change
    create_table :teaching_units do |t|
      t.string :title
      t.references :subtopic

      t.timestamps
    end
  end
end
