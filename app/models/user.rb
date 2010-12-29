require 'digest/sha2'

class User < ActiveRecord::Base
  # Callbacks
  before_create :encrypt_password
  after_create :password_to_nil

  # Restricciones
  validates :user, :name, :lastname, :email, :presence => true
  validates_uniqueness_of :user, :case_sensitive => false
  validates_length_of :user, :in => 5..30, :allow_nil => true,
    :allow_blank => true
  validates_length_of :password, :in => 5..128
  validates_length_of :name, :lastname, :email, :maximum => 255,
    :allow_nil => true, :allow_blank => true
  validates_confirmation_of :password, :if => :is_not_encrypted?
  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :allow_nil => true, :allow_blank => true

  def to_s
    [self.name, self.lastname].join(' ')
  end

  # Método invocado después de haber creado una instancia de la clase
  def password_to_nil
    self.password = nil
  end

  # Método para determinar si el usuario está o no habilitado
  def is_enable?
    self.enable == true
  end

   # Cifra la contraseña con SHA512
  def encrypt_password
    self.salt ||= self.create_new_salt
    self.password = User.digest(self.password, self.salt) if is_not_encrypted?
  end

  def create_new_salt
    Digest::SHA512.hexdigest(self.object_id.to_s + rand.to_s)
  end

  def self.digest(string, salt)
    Digest::SHA512.hexdigest("#{salt}-#{string}")
  end

  def is_not_encrypted?
    self.password &&
      (self.password.length < 120 || self.password !~ /^(\d|[a-f])+$/)
  end
end