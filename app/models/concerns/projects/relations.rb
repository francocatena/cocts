module Projects::Relations
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :questions, :validate => false
    has_and_belongs_to_many :teaching_units, -> { uniq }, :validate => false
    has_many :project_instances
    belongs_to :user
  end
end

