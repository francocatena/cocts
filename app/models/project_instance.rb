class ProjectInstance < ApplicationModel
  include Reports::PdfProject
  include ProjectInstances::Validations
  include ProjectInstances::Scopes
  include ProjectInstances::Relations
  include ProjectInstances::Rates
  include ProjectInstances::CustomAttributes
  include ProjectInstances::Initializer

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
end
