class ProjectInstance < ActiveRecord::Base
  serialize :forms, Array
  # Relaciones
  belongs_to :project
  has_many :question_instances, :dependent => :destroy
  accepts_nested_attributes_for :question_instances
  
  
  # Constantes
  TYPES = {
    :manual => 0,
    :interactive => 1
  }
  
  SOCIODEMOGRAPHIC_FORMS = [
    'country',
    'age',
    'genre',
    'student',
    'teacher',
    'teacher_level',
    'degree',
    'profession'
  ]
  
  # Restricciones
  validates :email, :presence => true,
    :length => { :maximum => 255 }
  validates_uniqueness_of :email, :scope => :project_id, :allow_nil => true, :allow_blank => true
  validates :email, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, 
    :allow_blank => true, :allow_nil => true    
  validates_length_of :first_name, :last_name, :email, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates_each :forms do |record, attr, value|
    unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
      record.errors.add attr, :inclusion
    end
  end
  
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
  
  def project_type_text
    I18n.t :"projects.#{TYPES.invert[self.project_type]}_type"
  end
  
  TYPES.each do |type, value|
    define_method(:"#{type}?") do
      self.project_type == value
    end
  end
  
end
