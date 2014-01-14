class Question < ApplicationModel
  # Scopes
  default_scope { order(
    [
      "#{Question.table_name}.dimension ASC",
      "#{Question.table_name}.code ASC"
    ].join(', ')
  )}

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
  has_many :answers, -> { order("#{Answer.table_name}.order ASC") }, dependent: :destroy
  has_and_belongs_to_many :teaching_units
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

  def self.search(search, page = 12)
    if search
      where('question ILIKE :q OR code ILIKE :q', :q => "%#{search}%").paginate(
        :page => page, :per_page => APP_LINES_PER_PAGE
      )
    else
      all.paginate(:page => page, :per_page => APP_LINES_PER_PAGE)
    end
  end

  def standard_deviation(project, average)
    summation = 0
    n = 0
    project.project_instances.each do |instance|
      instance.question_instances.each do |question|
        if question.question_text.eql? "[#{self.code}] #{self.question}"
          question.answer_instances.each do |answer|
            if attitudinal_assessment = answer.calculate_attitudinal_assessment
              summation += (attitudinal_assessment - average) ** 2
              n += 1
            end
          end
        end
      end
    end

    if n > 1
      Math.sqrt(summation.abs / (n - 1))
    else
      0
    end
  end

  def self.full_text(query_terms)
    options = text_query(query_terms, 'code','question')
    conditions = [options[:query]]
    parameters = options[:parameters]

    where(
      conditions.map { |c| "(#{c})" }.join(' OR '), parameters
    ).order(options[:order])
  end
end
