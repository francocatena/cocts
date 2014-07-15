module QuestionInstances::Relations
  extend ActiveSupport::Concern

  included do
    belongs_to :project_instance
    belongs_to :question
    has_many :answer_instances, -> {
      order("#{AnswerInstance.table_name}.order ASC")
    }, dependent: :destroy

    accepts_nested_attributes_for :answer_instances
  end
end
