class AnswerInstance < ActiveRecord::Base
  scope :ordered, order("position")
  # Constantes
  CATEGORIES = {
    :adecuate => 2,
    :plausible => 1,
    :naive => 0
  }
  VALUATIONS = (1..9).map(&:to_s) + ['E','S']
  
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
end
