module TeachingUnits::Relations
  extend ActiveSupport::Concern

  included do
    belongs_to :subtopic
    has_and_belongs_to_many :questions
    has_and_belongs_to_many :projects
  end
end
