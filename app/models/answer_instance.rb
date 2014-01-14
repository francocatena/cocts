class AnswerInstance < ApplicationModel
  scope :ordered, -> { order("position") }

  # Relaciones
  belongs_to :question_instance
  belongs_to :answer

  # Restricciones
  validates :answer_text, :order, :valuation, :answer_category, :presence => true
  validates_numericality_of :answer_category, :order, :only_integer => true,
      :allow_blank => true, :allow_nil => true
  validates_inclusion_of :answer_category, :in => CATEGORIES.values,
    :allow_blank => true, :allow_nil => true
  validates_inclusion_of :valuation, :in => VALUATIONS,
    :allow_blank => true, :allow_nil => true

  def calculate_attitudinal_assessment
    self.attitudinal_assessment = ['E', 'S'].include?(self.valuation) ? nil :
      CORRESPONDENCE_WITH_NORMALIZED_INDEX[self.answer_category][self.valuation.to_i]
  end
end
