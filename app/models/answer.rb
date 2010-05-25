class Answer < ActiveRecord::Base
  # Constantes
  CATEGORIES = {
    :adecuate => 2,
    :plausible => 1,
    :naive => 0
  }

  # Restricciones
  validates_presence_of :answer, :category, :order
  validates_numericality_of :order, :category, :only_integer => true,
    :allow_nil => true, :allow_blank => true
  validates_inclusion_of :category, :in => CATEGORIES.values,
    :allow_nil => true, :allow_blank => true

  # Relaciones
  belongs_to :question

  def category_text(short = false)
    type = short ? :shor_type : :long_type

    I18n.t "projects.answers.#{type}.#{CATEGORIES.invert[self.category]}"
  end
end