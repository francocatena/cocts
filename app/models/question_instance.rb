class QuestionInstance < ApplicationModel
  include QuestionInstances::Relations
  include QuestionInstances::Validations
  include QuestionInstances::Rates

  def initialize(attributes = nil, options = {})
    super(attributes, options)

    if self.question
      self.question.answers.each do |answer|
        unless self.answer_instances.detect { |ai| ai.answer_id == answer.id }
          self.answer_instances.build(
            :answer => answer,
            :answer_text => answer.answer,
            :answer_category => answer.category,
            :order => answer.order
          )
        end
      end
    end
  end
end
