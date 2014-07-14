module Questions::Rates
  def standard_deviation(project, average)
    summation = 0
    n = 0
    project.project_instances.each do |instance|
      instance.question_instances.each do |question|
        if question.question_text.eql? "[#{self.code}] #{self.question}"
          question.answer_instances.each do |answer|
            if attitudinal_assessment = answer.calculate_attitudinal_assessment
              summation += (attitudinal_assessment - average) ** 2
              n += 1
            end
          end
        end
      end
    end

    if n > 1
      Math.sqrt(summation.abs / (n - 1))
    else
      0
    end
  end
end
