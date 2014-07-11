class ProjectInstance < ApplicationModel
  include Reports::PdfProject
  include ProjectInstances::Validations
  include ProjectInstances::Scopes
  include ProjectInstances::Relations
  include ProjectInstances::Rates
  include ProjectInstances::CustomAttributes

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
end
