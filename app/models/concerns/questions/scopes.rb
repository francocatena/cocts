module Questions::Scopes
  extend ActiveSupport::Concern

  included do
    default_scope { order(
      [
        "#{Question.table_name}.dimension ASC",
        "#{Question.table_name}.code ASC"
      ].join(', ')
    )}
  end
end
