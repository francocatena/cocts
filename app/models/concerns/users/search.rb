module Users::Search
  extend ActiveSupport::Concern

  module ClassMethods
    def search(search, page)
      if search
        where('name ILIKE :q OR lastname ILIKE :q OR email ILIKE :q OR user ILIKE :q',
          :q => "%#{search}%").order(
          "#{User.table_name}.user ASC"
          ).paginate(
            :page => page,
            :per_page => APP_LINES_PER_PAGE
          )
      else
        all.order("#{User.table_name}.user ASC").paginate(
          :page => page,
          :per_page => APP_LINES_PER_PAGE
        )
      end
    end
  end
end
