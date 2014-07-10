class Project < ApplicationModel
  include Reports::AttitudinalRates
  include Reports::PdfProject
  include Projects::Validations
  include Projects::Relations

  serialize :forms, Array
  # Scopes
  default_scope { order('name') }

  # Atributos no persistentes
  attr_accessor :nested_question
  attr_accessor :nested_teaching_unit

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
end
