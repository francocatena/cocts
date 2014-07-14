class Question < ApplicationModel
  include Questions::Validations
  include Questions::Relations

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
