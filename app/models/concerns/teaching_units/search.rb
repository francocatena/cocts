module TeachingUnits::Search
  extend ActiveSupport::Concern

  module ClassMethods
    def full_text(query_terms)
      options = text_query(query_terms, 'title')
      conditions = [options[:query]]
      parameters = options[:parameters]

      where(
        conditions.map { |c| "(#{c})" }.join(' OR '), parameters
      ).order(options[:order])
    end

    def search(search, page)
      if search
        where('title ILIKE :title', title: "%#{search}%").order(
          "#{TeachingUnit.table_name}.title ASC"
        ).paginate(
          page: page,
          per_page: APP_LINES_PER_PAGE
        )
      else
        all.order("#{TeachingUnit.table_name}.title ASC").paginate(
          page: page,
          per_page: APP_LINES_PER_PAGE
        )
      end
    end
  end
end
