module Projects::Search
  extend ActiveSupport::Concern

  module ClassMethods
    def search(search, user, page)
      if search
        sql_search = where("#{Project.table_name}.name ILIKE :q OR #{Project.table_name}.identifier ILIKE :q", q: "%#{search}%")
      else
        sql_search = all
      end
      if user.private
        sql_search.where('user_id = :id', id: user.id).paginate(page: page, per_page: APP_LINES_PER_PAGE)
      else
        sql_search.paginate(page: page, per_page: APP_LINES_PER_PAGE )
      end
    end
  end
end
