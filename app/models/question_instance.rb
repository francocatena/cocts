class QuestionInstance < ActiveRecord::Base
  # Relaciones
  belongs_to :project_instance
  belongs_to :question
  has_many :answer_instances, :dependent => :destroy,
    :order => "#{AnswerInstance.table_name}.order ASC"
  accepts_nested_attributes_for :answer_instances
  
  # Restricciones
  validates :question_text, :presence => true
  
  def initialize(attributes = nil)
    super(attributes)
    
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
