class Question < ApplicationModel
  include Questions::Validations
  include Questions::Relations
  include Questions::Search
  include Questions::Scopes
  include Questions::Rates

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
end
