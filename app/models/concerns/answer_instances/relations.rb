module AnswerInstances::Relations
  extend ActiveSupport::Concern

  included do
    belongs_to :question_instance
    belongs_to :answer
  end
end
