module Questions::Callbacks
  extend ActiveSupport::Concern

  included do
    before_destroy :can_be_destroyed?
  end

  def can_be_destroyed?
    self.projects.blank?
  end
end

