module QuestionInstances::Rates
  def attitudinal_assessment_average
    assessments = 0
    count = 0

    self.answer_instances.each do |a_i|
      if a_i.attitudinal_assessment.present?
        assessments += a_i.attitudinal_assessment
        count += 1
      end
    end

    unless count == 0
      assessments / count
    end
  end
end
