module Subtopics::Validations
  extend ActiveSupport::Concern

  included do
    validates :title, :code, presence: true
    validates :title, uniqueness: true
    validates :code, numericality: { only_integer: true },
      allow_nil: true, allow_blank: true
  end
end
