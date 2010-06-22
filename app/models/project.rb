class Project < ActiveRecord::Base
  serialize :forms, Array

  attr_accessor :nested_question

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
  validates_format_of :identifier, :with => /\A[A-Za-z][A-Za-z0-9\-]*\z/,
    :allow_nil => true, :allow_blank => true
  validates_presence_of :name, :identifier, :description
  validates_uniqueness_of :identifier, :allow_nil => true, :allow_blank => true
  validates_numericality_of :year, :only_integer => true, :allow_nil => true,
    :allow_blank => true, :greater_than => 1000, :less_than => 3000
  validates_length_of :name, :identifier, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates_date :valid_until, :on_or_after => lambda { Date.today },
    :allow_nil => false, :allow_blank => false
  validates_each :forms do |record, attr, value|
    unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
      record.errors.add attr, :inclusion
    end
  end
  validates_each :questions do |record, attr, value|
    if value.reject(&:marked_for_destruction?).empty?
      record.errors.add attr, :blank
    end
  end

  has_and_belongs_to_many :questions, :validate => false, :order => 'code ASC',
    :uniq => true

  def initialize(attributes = nil)
    super(attributes)

    self.project_type ||= TYPES[:interactive]
    self.forms ||= SOCIODEMOGRAPHIC_FORMS
  end

  def to_param
    self.identifier
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