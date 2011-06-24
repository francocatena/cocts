class ProjectInstance < ActiveRecord::Base
  # Relaciones
  belongs_to :project
  has_many :question_instances, :dependent => :destroy
  accepts_nested_attributes_for :question_instances
  
  # Restricciones
  validates :email, :presence => true,
    :length => { :maximum => 255 }
  validates_uniqueness_of :email, :allow_nil => true, :allow_blank => true
  validates :email, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, 
    :allow_blank => true, :allow_nil => true    
  validates_length_of :first_name, :last_name, :email, :maximum => 255, :allow_nil => true,
    :allow_blank => true

  def initialize(attributes = nil)
    super(attributes)
    
    if self.project
      self.project.questions.each do |question|
        unless self.question_instances.detect {|qi| qi.question_id == question.id}
          self.question_instances.build(
            :question => question,
            :question_text => "[#{question.code}] #{question.question}"
          )
        end
      end
    end
  end
end
