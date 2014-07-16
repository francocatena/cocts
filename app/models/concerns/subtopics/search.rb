module Subtopics::Search
  extend ActiveSupport::Concern

  module ClassMethods
    def search(search, page)
      if search
        where('title ILIKE :title OR code = :code', title: "%#{search}%",
          code: search.to_i).order(
            "#{Subtopic.table_name}.code ASC"
          ).paginate(
            page: page,
            per_page: APP_LINES_PER_PAGE
          )
      else
        all.order("#{Subtopic.table_name}.code ASC").paginate(
          page: page,
          per_page: APP_LINES_PER_PAGE
        )
      end
    end
  end
end
