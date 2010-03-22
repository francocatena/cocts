class Project < ActiveRecord::Base
  # Constantes
  TYPES = {
    :manual => 0,
    :interactive => 1
  }

  # Restricciones
  validates_presence_of :name, :description
  validates_numericality_of :year, :only_integer => true, :allow_nil => true,
    :allow_blank => true, :greater_than => 1000, :less_than => 3000
  validates_length_of :name, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates_date :valid_until, :on_or_after => lambda { Date.today },
    :allow_nil => false, :allow_blank => false

  def initialize(attributes = nil)
    super(attributes)

    self.project_type ||= TYPES[:interactive]
  end

  TYPES.each do |type, value|
    define_method("#{type}?") do
      self.project_type == value
    end
  end

  def project_type_text
    I18n.t "projects.#{TYPES.invert[self.project_type]}_type"
  end
end