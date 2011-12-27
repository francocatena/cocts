class Answer < ApplicationModel
  # Constantes
  CATEGORIES = {
    :adecuate => 2,
    :plausible => 1,
    :naive => 0
  }

  # Restricciones
  validates :answer, :category, :order, :presence => true
  validates_numericality_of :order, :category, :only_integer => true,
    :allow_nil => true, :allow_blank => true
  validates_inclusion_of :category, :in => CATEGORIES.values,
    :allow_nil => true, :allow_blank => true

  # Relaciones
  belongs_to :question
  
  def ==(other)
    if other.kind_of?(Answer)
      if other.new_record?
        other.object_id == self.object_id
      else
        other.id == self.id
      end
    end
  end

  def category_text(short = false)
    type = short ? :shor_type : :long_type

    I18n.t :"projects.answers.#{type}.#{CATEGORIES.invert[self.category]}"
  end
end