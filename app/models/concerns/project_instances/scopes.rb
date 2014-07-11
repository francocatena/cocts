module ProjectInstances::Scopes
  extend ActiveSupport::Concern

  included do
    default_scope { order('first_name') }
    scope :with_project, ->(project_id) {
      where('project_id = :id', id: project_id)
    }
  end
end
