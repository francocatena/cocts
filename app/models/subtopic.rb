class Subtopic < ApplicationModel
  include Subtopics::CustomAttributes
  include Subtopics::Relations
  include Subtopics::Validations
  include Subtopics::Search

  def initialize(attributes = nil, options = {})
    super(attributes, options)
    self.teaching_units ||= TeachingUnit.new
  end

  def as_json(options = nil)
    default_options = { :only => [:id], :methods => [:label] }

    super(default_options.merge(options || {}))
  end
end
