module Questions::Search
  extend ActiveSupport::Concern

  module ClassMethods
    def full_text(query_terms)
      options = text_query(query_terms, 'code','question')
      conditions = [options[:query]]
      parameters = options[:parameters]

      where(
        conditions.map { |c| "(#{c})" }.join(' OR '), parameters
      ).order(options[:order])
    end

    def search(search, page = 12)
      if search
        where('question ILIKE :q OR code ILIKE :q', :q => "%#{search}%").paginate(
          :page => page, :per_page => APP_LINES_PER_PAGE
        )
      else
        all.paginate(:page => page, :per_page => APP_LINES_PER_PAGE)
      end
    end
  end
end
