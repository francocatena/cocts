module Projects::Scopes
  extend ActiveSupport::Concern

  included do
    default_scope { order('name') }
  end
end
