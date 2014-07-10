class User < ApplicationModel
  include Users::Password
  include Users::Validations

  # Relaciones
  has_many :projects

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

  def self.search(search, page)
    if search
      where('name ILIKE :q OR lastname ILIKE :q OR email ILIKE :q OR user ILIKE :q',
        :q => "%#{search}%").order(
        "#{User.table_name}.user ASC"
        ).paginate(
          :page => page,
          :per_page => APP_LINES_PER_PAGE
        )
    else
      all.order("#{User.table_name}.user ASC").paginate(
        :page => page,
        :per_page => APP_LINES_PER_PAGE
      )
    end
  end
end
