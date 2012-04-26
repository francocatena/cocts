class AddAttitudinalAssessmentToAnswerInstance < ActiveRecord::Migration
  def change
    add_column :answer_instances, :attitudinal_assessment, :float
  end
end
