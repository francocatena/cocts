module Users::Relations
  extend ActiveSupport::Concern

  included do
    has_many :projects
  end
end

