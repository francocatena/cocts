require 'test_helper'

# Clase para probar el modelo "User"
class UserTest < ActiveSupport::TestCase
  fixtures :users

  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @user = User.find users(:admin).id
  end

  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of User, @user
    assert_equal users(:admin).name, @user.name
    assert_equal users(:admin).lastname, @user.lastname
    assert_equal users(:admin).email, @user.email
    assert_equal users(:admin).user, @user.user
    assert_equal users(:admin).password, @user.password
    assert_equal users(:admin).enable, @user.enable
  end

  # Prueba la creación de un usuario
  test 'create' do
    assert_difference 'User.count' do
      @user = User.create(
        :user => 'new_user',
        :name => 'New name',
        :lastname => 'New lastname',
        :password => 'new_password_123',
        :password_confirmation => 'new_password_123',
        :email => 'new_user@users.com',
        :enable => true
      )
    end
  end

  # Prueba de actualización de un usuario
  test 'update' do
    assert_no_difference 'User.count' do
      assert @user.update_attributes(:user => 'updated_user'),
        @user.errors.full_messages.join('; ')
    end

    @user.reload
    assert_equal 'updated_user', @user.user
  end

  # Prueba de eliminación de usuarios
  test 'delete' do
    assert_difference('User.count', -1) { @user.destroy }
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @user.user = '   '
    @user.email = '   '
    @user.name = nil
    @user.lastname = nil
    assert @user.invalid?
    assert_equal 4, @user.errors.count
    assert_equal [error_message_from_model(@user, :user, :blank)],
      @user.errors[:user]
    assert_equal [error_message_from_model(@user, :email, :blank)],
      @user.errors[:email]
    assert_equal [error_message_from_model(@user, :name, :blank)],
      @user.errors[:name]
    assert_equal [error_message_from_model(@user, :lastname, :blank)],
      @user.errors[:lastname]
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates formated attributes' do
    @user.email = 'incorrect@format'
    assert @user.invalid?
    assert_equal 1, @user.errors.count
    assert_equal [error_message_from_model(@user, :email, :invalid)],
      @user.errors[:email]
  end

  test 'validates unique attributes' do
    @user.user = users(:disable).user
    assert @user.invalid?
    assert_equal 1, @user.errors.count
    assert_equal [error_message_from_model(@user, :user, :taken)],
      @user.errors[:user]
  end

  test 'validates lenght attributes' do
    @user.user = 'abcd'
    @user.password = 'a9A'
    assert @user.invalid?
    assert_equal 2, @user.errors.count
    assert_equal [error_message_from_model(@user, :user, :too_short,
      :count => 5)], @user.errors[:user]
    assert_equal [error_message_from_model(@user, :password, :too_short,
      :count => 5)], @user.errors[:password]

    @user.user = 'abcd' * 10
    @user.password = 'admin123' * 20
    @user.password_confirmation = 'admin123' * 20
    @user.name = 'abcde' * 52
    @user.lastname = 'abcde' * 52
    @user.email = "#{'abcde' * 52}@somewhere.com"
    assert @user.invalid?
    assert_equal 5, @user.errors.count
    assert_equal [error_message_from_model(@user, :user, :too_long,
      :count => 30)], @user.errors[:user]
    assert_equal [error_message_from_model(@user, :password, :too_long,
      :count => 128)], @user.errors[:password]
    assert_equal [error_message_from_model(@user, :name, :too_long,
      :count => 255)], @user.errors[:name]
    assert_equal [error_message_from_model(@user, :lastname, :too_long,
      :count => 255)], @user.errors[:lastname]
    assert_equal [error_message_from_model(@user, :email, :too_long,
      :count => 255)], @user.errors[:email]
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates confirmed attributes' do
    @user.password = 'admin124'
    @user.password_confirmation = 'admin125'
    assert @user.invalid?
    assert_equal 1, @user.errors.count
    assert_equal [error_message_from_model(@user, :password, :confirmation)],
      @user.errors[:password]
  end
end