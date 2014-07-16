class TeachingUnit < ApplicationModel
  include TeachingUnits::CustomAttributes
  include TeachingUnits::Relations
  include TeachingUnits::Validations
  include TeachingUnits::Search

  def initialize(attributes = nil, options = {})
    super(attributes, options)
  end

  def as_json(options = nil)
    default_options = { :only => [:id], :methods => [:label] }

    super(default_options.merge(options || {}))
  end
end
