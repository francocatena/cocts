class TeachingUnit < ApplicationModel
  include TeachingUnits::CustomAttributes
  include TeachingUnits::Relations
  include TeachingUnits::Validations

  def initialize(attributes = nil, options = {})
    super(attributes, options)
  end

  def as_json(options = nil)
    default_options = { :only => [:id], :methods => [:label] }

    super(default_options.merge(options || {}))
  end

  def self.full_text(query_terms)
    options = text_query(query_terms, 'title')
    conditions = [options[:query]]
    parameters = options[:parameters]

    where(
      conditions.map { |c| "(#{c})" }.join(' OR '), parameters
    ).order(options[:order])
  end

  def self.search(search, page)
    if search
      where('title ILIKE :q', :q => "%#{search}%").order(
        "#{TeachingUnit.table_name}.title ASC"
      ).paginate(
        :page => page,
        :per_page => APP_LINES_PER_PAGE
      )
    else
      all.order("#{TeachingUnit.table_name}.title ASC").paginate(
        :page => page,
        :per_page => APP_LINES_PER_PAGE
      )
    end
  end

end
