class Answer < ApplicationModel
  # Constantes
  CATEGORIES = {
    :adecuate => 2,
    :plausible => 1,
    :naive => 0
  }

  # Restricciones
  validates :answer, :category, :presence => true
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