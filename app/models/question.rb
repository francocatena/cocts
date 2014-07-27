class Question < ApplicationModel
  include Questions::Validations
  include Questions::Relations
  include Questions::Search
  include Questions::Scopes
  include Questions::Rates
  include Questions::CustomAttributes
  include Questions::Callbacks

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
    default_options = { only: [:id], methods: [:label, :informal] }

    super(default_options.merge(options || {}))
  end

  def dimension_text
    I18n.t :"questions.dimensions.#{self.dimension}"
  end
end
