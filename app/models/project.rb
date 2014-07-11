class Project < ApplicationModel
  include Reports::AttitudinalRates
  include Reports::PdfProject
  include Projects::Validations
  include Projects::Relations
  include Projects::Search
  include Projects::CustomAttributes
  include Projects::Callbacks

  # Scopes
  default_scope { order('name') }

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

  def generate_identifier
    self.update_attribute(:identifier,
      [self.id, self.short_group_type_text, self.short_test_type_text].join('-')
    )
  end
end
