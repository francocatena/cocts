module Subtopics::Relations
  extend ActiveSupport::Concern

  included do
    has_many :teaching_units
  end
end
