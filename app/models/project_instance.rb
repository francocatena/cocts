class ProjectInstance < ApplicationModel
  include Reports::PdfProject

  serialize :forms, Array
  # Scopes
  default_scope { order('first_name') }
  scope :with_project, ->(project_id) { where('project_id = :id', id: project_id) }

  # Atributos no persistentes
  attr_accessor :manual_degree, :manual_degree_university

  # Relaciones
  belongs_to :project
  has_many :question_instances, :dependent => :destroy
  accepts_nested_attributes_for :question_instances

  # Restricciones
  validates :first_name, :presence => true
  validates_numericality_of :age, :only_integer => true, :allow_nil => true,
    :allow_blank => true
  validates_uniqueness_of :first_name, :scope => :project_id, :allow_nil => true, :allow_blank => true
  validates_length_of :professor_name, :first_name, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates_each :forms do |record, attr, value|
    unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
      record.errors.add attr, :inclusion
    end
  end

  def initialize(attributes = nil, options = {})
    super(attributes, options)

    if self.project
      self.forms = self.project.forms
      self.name = self.project.name
      self.identifier = self.project.identifier
      self.group_type = self.project.group_type
      self.group_name = self.project.group_name
      self.description = self.project.description
      self.year = self.project.year
      self.project_type = self.project.project_type
      self.valid_until = self.project.valid_until
      if self.project.teaching_units.empty?
        self.project.questions.each do |question|
          unless self.question_instances.detect {|qi| qi.question_id == question.id}
            self.question_instances.build(
              :question => question,
              :question_text => "[#{question.code}] #{question.question}"
            )
          end
        end
      else
        self.project.teaching_units.each do |teaching_unit|
          teaching_unit.questions.each do |question|
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

    self.degree = self.manual_degree if self.manual_degree.present?
    self.degree_university = self.manual_degree_university if self.manual_degree_university.present?
  end

  def project_type_text
    I18n.t :"projects.#{TYPES.invert[self.project_type]}_type"
  end

  TYPES.each do |type, value|
    define_method(:"#{type}?") do
      self.project_type == value
    end
  end

  def student_data
    if self.first_name && self.genre && self.age
      "#{self.first_name} (#{self.age}, #{I18n.t "projects.questionnaire.genre.options.#{self.genre}"})"
    elsif self.first_name
      self.first_name
    end
  end

  def calculate_attitudinal_rates
    calculate_attitudinal_assessment
    self.plausible_attitude_index = calculate_attitudinal_index(1)
    self.naive_attitude_index = calculate_attitudinal_index(0)
    self.adecuate_attitude_index = calculate_attitudinal_index(2)

  end

  def calculate_attitudinal_assessment
    self.question_instances.each do |qi|
      qi.answer_instances.each do |ai|
        ai.calculate_attitudinal_assessment
      end
    end
  end

  def calculate_attitudinal_index(category)
    total = 0
    index = 0
    self.question_instances.each do |qi|
      qi.answer_instances.each do |ai|
        if ai.answer_category == category && ai.attitudinal_assessment
          index+= ai.attitudinal_assessment
          total+= 1
        end
      end
    end
    if total == 0
      0
    else
      index/total
    end
  end

  def attitudinal_global_index
    (self.plausible_attitude_index + self.naive_attitude_index + self.adecuate_attitude_index) / 3
  end

  def standard_deviation(average)
    summation = 0
    n = 0
    self.question_instances.each do |question|
      question.answer_instances.each do |answer|
        if attitudinal_assessment = answer.calculate_attitudinal_assessment
          summation += (attitudinal_assessment - average) ** 2
          n += 1
        end
      end
    end

    if n > 1
      Math.sqrt(summation.abs / (n - 1))
    else
      0
    end
  end
end
