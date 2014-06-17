class Project < ApplicationModel
  include Reports::AttitudinalRates
  include Reports::PdfProject

  serialize :forms, Array
  # Scopes
  default_scope { order('name') }

  # Atributos no persistentes
  attr_accessor :nested_question
  attr_accessor :nested_teaching_unit

  # Restricciones
  validates :name, :test_type, :group_name, :group_type, :description, :valid_until,
    :presence => true
  validates_uniqueness_of :identifier, :allow_nil => true, :allow_blank => true
  validates_numericality_of :year, :only_integer => true, :allow_nil => true,
    :allow_blank => true, :greater_than => 1000, :less_than => 3000
  validates_length_of :name, :identifier, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates :identifier, :exclusion => { :in => %w(admin ayuda help) }
  validates_date :valid_until, :on_or_after => lambda { Date.today },
    :allow_nil => false, :allow_blank => false, :if => :interactive?
  validates_each :forms do |record, attr, value|
    unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
      record.errors.add attr, :inclusion
    end
  end
  validate :questions_xor_teaching_units

  # Relaciones
  has_and_belongs_to_many :questions, :validate => false
  has_and_belongs_to_many :teaching_units, -> { uniq }, :validate => false
  has_many :project_instances
  belongs_to :user

  # Callbacks
  before_destroy :can_be_destroyed?

  def initialize(attributes = nil, options = {})
    super(attributes, options)

    self.project_type ||= TYPES[:interactive]
    self.forms ||= SOCIODEMOGRAPHIC_FORMS
  end

  def is_valid?
    Time.now < self.valid_until
  end

  def to_param
    self.identifier
  end

  def can_be_destroyed?
    self.project_instances.blank?
  end

  TYPES.each do |type, value|
    define_method(:"#{type}?") do
      self.project_type == value
    end
  end

  def set_parent_data(project)
    self.name = project.name
    self.description = project.description
    self.valid_until = project.valid_until
    self.year = project.year
    self.forms = project.forms
    self.teaching_units = project.teaching_units
    self.questions = project.questions
  end

  def project_type_text
    I18n.t "projects.#{TYPES.invert[self.project_type]}_type"
  end

  def project_group_type_text
    I18n.t "projects.questionnaire.group_type.options.#{self.group_type}"
  end

  def short_test_type_text
    self.test_type[0..2]
  end

  def short_group_type_text
    self.group_type[0,1]
  end

  def project_test_type_text
    I18n.t "projects.questionnaire.test_type.options.#{self.test_type}"
  end

  def self.search(search, user, page)
    if search
      sql_search = where("#{Project.table_name}.name ILIKE :q OR #{Project.table_name}.identifier ILIKE :q", :q => "%#{search}%")
    else
      sql_search = all
    end
    if user.private
      sql_search.where('user_id = :id', :id => user.id).paginate(:page => page, :per_page => APP_LINES_PER_PAGE)
    else
      sql_search.paginate(:page => page, :per_page => APP_LINES_PER_PAGE )
    end
  end

  def generate_identifier
    self.update_attribute(:identifier,
      [self.id, self.short_group_type_text, self.short_test_type_text].join('-')
    )
  end

  private

    def questions_xor_teaching_units
      if !(questions.blank? ^ teaching_units.blank?)
        self.errors[:question_ids] << t('projects.empty_questions_error')
      end
    end
end
