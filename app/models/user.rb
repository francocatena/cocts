class User < ApplicationModel
  include Users::Password
  include Users::Validations
  include Users::Relations
  include Users::Search

  before_destroy :can_be_destroyed?

  def to_s
    [self.name, self.lastname].join(' ')
  end

  def can_be_destroyed?
    self.projects.blank?
  end

  # Método para determinar si el usuario está o no habilitado
  def is_enable?
    self.enable == true
  end
end
