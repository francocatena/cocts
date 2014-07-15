module Answers::Rates
  def calculate_global_attitudinal_assessment
    index = 0
    total = 0
    answer_instances = AnswerInstance.where(:answer_text => self.answer,
      :order => self.order, :answer_category => self.category)
    if answer_instances
      answer_instances.each do |ai|
        index+= ai.attitudinal_assessment
        total+= 1
      end
      if total == 0
        total
      else
        index/total
      end
    end
  end
end
