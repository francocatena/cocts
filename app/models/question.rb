class Question < ActiveRecord::Base
  DIMENSIONS = 1..9

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

  def dimension_text
    I18n.t :"questions.dimensions.#{self.dimension}"
  end

  def can_be_destroyed?
    self.projects.blank?
  end

end
