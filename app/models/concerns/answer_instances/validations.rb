module AnswerInstances::Validations
  extend ActiveSupport::Concern

  included do
    validates :answer_text, :order, :valuation, :answer_category, presence: true
    validates_numericality_of :answer_category, :order, only_integer: true,
      allow_blank: true, allow_nil: true
    validates_inclusion_of :answer_category, in: CATEGORIES.values,
      allow_blank: true, allow_nil: true
    validates_inclusion_of :valuation, in: VALUATIONS,
      allow_blank: true, allow_nil: true
  end
end
