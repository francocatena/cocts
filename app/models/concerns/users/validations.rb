module Users::Validations
  extend ActiveSupport::Concern

  included do
    validates :user, :name, :lastname, :email, :presence => true
    validates_uniqueness_of :user, :case_sensitive => false, :allow_nil => true,
      :allow_blank => true
    validates_uniqueness_of :email, :allow_nil => true, :allow_blank => true
    validates_length_of :user, :in => 5..30, :allow_nil => true,
      :allow_blank => true
    validates_length_of :password, :in => 5..128
    validates_length_of :name, :lastname, :email, :maximum => 255,
      :allow_nil => true, :allow_blank => true
    validates_confirmation_of :password, :if => :is_not_encrypted?
    validates_format_of :email,
      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
      :multiline => true, :allow_nil => true, :allow_blank => true
  end
end
