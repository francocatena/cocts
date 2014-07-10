require 'digest/sha2'

module Users::Password
  extend ActiveSupport::Concern

  included do
    before_create :encrypt_password
    after_create :password_to_nil
    before_update :encrypt_password
    after_update :password_to_nil
  end

  module ClassMethods
    def digest(string, salt)
      Digest::SHA512.hexdigest("#{salt}-#{string}")
    end
  end

   # Cifra la contraseña con SHA512
  def encrypt_password
    self.salt ||= self.create_new_salt
    self.password = User.digest(self.password, self.salt) if is_not_encrypted?
  end

  # Método invocado después de haber creado una instancia de la clase
  def password_to_nil
    self.password = nil
  end

  def create_new_salt
    Digest::SHA512.hexdigest(self.object_id.to_s + rand.to_s)
  end

  def is_not_encrypted?
    self.password &&
      (self.password.length < 120 || self.password !~ /^(\d|[a-f])+$/)
  end
end
