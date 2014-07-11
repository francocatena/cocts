module Projects::Callbacks
  extend ActiveSupport::Concern

  included do
    before_destroy :can_be_destroyed?
  end

  def can_be_destroyed?
    self.project_instances.blank?
  end
end
