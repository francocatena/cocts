class Question < ActiveRecord::Base
  DIMENSIONS = 1..9

  # Restricciones
  validates_presence_of :code, :question, :dimension
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

  accepts_nested_attributes_for :answers, :allow_destroy => true

  def dimension_text
    I18n.t("questions.dimensions.#{self.dimension}")
  end
end