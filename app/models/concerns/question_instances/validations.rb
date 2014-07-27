module QuestionInstances::Validations
  extend ActiveSupport::Concern

  included do
    validates :question_text, presence: true
  end
end
