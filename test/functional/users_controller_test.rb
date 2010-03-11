require 'test_helper'

# Pruebas para el controlador de usuarios
class UsersControllerTest < ActionController::TestCase
  fixtures :users

  # Inicializa de forma correcta todas las variables que se utilizan en las
  # pruebas
  def setup
    @public_actions = [:login]
    @private_actions = [:index, :show, :new, :edit, :create, :update, :destroy,
      :edit_password, :update_password, :edit_personal_data,
      :update_personal_data, :logout]
  end

  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    @private_actions.each do |action|
      get action
      assert_redirected_to login_users_path
      assert_equal I18n.t(:'messages.must_be_authenticated'), flash[:notice]
    end

    @public_actions.each do |action|
      get action
      assert_response :success
    end
  end

  test 'login form' do
    get :login
    assert_response :success
    assert_not_nil assigns(:user)
    assert_select '#error_body', false
    assert_template 'users/login'
  end

  # Prueba que no pueda autenticarse un usuario que no es válido
  test 'invalid user and password attempt' do
    post :create_session, :user =>
      { :user => 'someone', :password => 'without authorization' }

    assert_redirected_to login_users_path
    assert_equal I18n.t(:'messages.invalid_user_or_password'), flash[:notice]
  end

  test 'invalid password attempt' do
    post :create_session,
      :user => {
        :user => users(:admin).user,
        :password => 'wrong password'
      }

    assert_redirected_to login_users_path
    assert_equal I18n.t(:'messages.invalid_user_or_password'), flash[:notice]
  end

  test 'disable user attempt' do
    post :create_session,
      :user => {
        :user => users(:disable).user,
        :password => users(:disable).password
      }

    assert_redirected_to login_users_path
    assert_equal I18n.t(:'messages.invalid_user_or_password'), flash[:notice]
  end

  test 'login sucesfully' do
    post :create_session,
      :user => {
        :user => users(:admin).user,
        :password => users(:admin).password
      }
    assert_redirected_to users_path
  end

  test 'list users' do
    perform_auth
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    assert_select '#error_body', false
    assert_template 'users/index'
  end

  test 'show user' do
    perform_auth
    get :show, :id => users(:admin)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_select '#error_body', false
    assert_template 'users/show'
  end

  test 'new user' do
    perform_auth
    get :new
    assert_response :success
    assert_not_nil assigns(:user)
    assert_select '#error_body', false
    assert_template 'users/new'
  end

  test 'create user' do
    perform_auth
    assert_difference 'User.count' do
      post :create, {
        :user => {
          :user => 'new_user',
          :name => 'New name',
          :lastname => 'New lastname',
          :password => 'new_password_123',
          :password_confirmation => 'new_password_123',
          :email => 'new_user@users.com',
          :enable => true
        }
      }
    end

    assert_redirected_to users_path
    assert_not_nil assigns(:user)
    assert_equal 'new_user', assigns(:user).user
  end

  test 'edit user' do
    perform_auth
    get :edit, :id => users(:admin)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_select '#error_body', false
    assert_template 'users/edit'
  end

  test 'update user' do
    perform_auth
    assert_no_difference 'User.count' do
      put :update, {
        :id => users(:admin),
        :user => {
          :user => 'updated_user',
          :name => 'Updated name',
          :lastname => 'Updated lastname',
          :password => 'updated_password_123',
          :password_confirmation => 'updated_password_123',
          :email => 'updated_user@users.com',
          :enable => true
        }
      }
    end

    assert_redirected_to users_path
    assert_not_nil assigns(:user)
    assert_equal 'updated_user', assigns(:user).user
  end

  test 'destroy user' do
    perform_auth
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:admin)
    end

    assert_redirected_to users_path
  end

  test 'edit password' do
    perform_auth
    get :edit_password
    assert_response :success
    assert_select '#error_body', false
    assert_template 'users/edit_password'
  end

  test 'update password' do
    user = User.find users(:admin).id

    perform_auth user
    put :update_password, {
      :user => {
        :password => 'new_password_123',
        :password_confirmation => 'new_password_123'
      }
    }

    assert_redirected_to login_users_path
    assert_equal User.digest('new_password_123', user.salt),
      user.reload.password
  end

  test 'edit personal data' do
    perform_auth
    get :edit_personal_data
    assert_response :success
    assert_select '#error_body', false
    assert_template 'users/edit_personal_data'
  end

  test 'update personal data' do
    user = User.find users(:admin).id

    perform_auth user
    put :update_personal_data, {
      :user => {
        :name => 'Updated name',
        :lastname => 'Updated lastname',
        :email => 'updated@email.com'
      }
    }

    assert_redirected_to edit_personal_data_user_path(user)
    assert_not_nil assigns(:user)
    assert_equal 'updated@email.com', user.reload.email
  end

  test 'logout' do
    perform_auth
    get :logout
    assert_nil session[:user_id]
    assert_redirected_to login_users_path
  end
end