class Question < ActiveRecord::Base
  DIMENSIONS = 1..9
    
  # Alias de atributos
  alias_attribute :informal, :question
  alias_attribute :label, :code

  # Restricciones
  validates :code, :question, :dimension, :presence => true
  validates_uniqueness_of :code, :allow_blank => true, :allow_nil => true
  validates_length_of :code, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates_format_of :code, :with => /\A\d+\Z/,
    :allow_blank => true, :allow_nil => true
  validates_numericality_of :dimension, :only_integer => true,
    :allow_blank => true, :allow_nil => true
  validates_inclusion_of :dimension, :in => DIMENSIONS, :allow_blank => true,
    :allow_nil => true

  # Relaciones
  has_many :answers, :dependent => :destroy,
    :order => "#{Answer.table_name}.order ASC"
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :teaching_units

  accepts_nested_attributes_for :answers, :allow_destroy => true

  before_destroy :can_be_destroyed?
  
  def ==(other)
    if other.kind_of?(Question)
      if other.new_record?
        other.object_id == self.object_id
      else
        other.id == self.id
      end
    end
  end
  
  def as_json(options = nil)
    default_options = { :only => [:id], :methods => [:label, :informal] }
    
    super(default_options.merge(options || {}))
  end

  def dimension_text
    I18n.t :"questions.dimensions.#{self.dimension}"
  end

  def can_be_destroyed?
    self.projects.blank?
  end
  
  def self.search(search)
  if search
    where('question LIKE ? OR code LIKE ?', "%#{search}%", "%#{search}%")
  else
    scoped
  end
end



end
