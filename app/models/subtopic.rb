class Subtopic < ApplicationModel
  include Subtopics::CustomAttributes
  include Subtopics::Relations
  include Subtopics::Validations

  def initialize(attributes = nil, options = {})
    super(attributes, options)
    self.teaching_units ||= TeachingUnit.new
  end

  def as_json(options = nil)
    default_options = { :only => [:id], :methods => [:label] }

    super(default_options.merge(options || {}))
  end

  def self.search(search, page)
    if search
      where('title ILIKE :t OR code = :c', :t => "%#{search}%", :c => search.to_i).order(
        "#{Subtopic.table_name}.code ASC"
      ).paginate(
        :page => page,
        :per_page => APP_LINES_PER_PAGE
      )
    else
      all.order("#{Subtopic.table_name}.code ASC").paginate(
        :page => page,
        :per_page => APP_LINES_PER_PAGE
      )
    end
  end
end
