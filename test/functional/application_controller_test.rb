require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    @controller.send :reset_session
    @controller.send(:session)[:user_id] = users(:admin).id
    @controller.send :response=, @response
    @controller.send :request=, @request
    @controller.send :action_name=, 'application_controller_test_action'
  end

  test 'sucess login check function' do
    assert session[:user_id]

    assert @controller.send(:login_check)
    assert @controller.instance_variable_defined?(:@auth_user)
  end

  test 'load auth user function' do
    assert session[:user_id]

    assert @controller.send(:load_auth_user)
    assert @controller.instance_variable_defined?(:@auth_user)
  end

  test 'sucess auth function' do
    assert !@controller.instance_variable_defined?(:@auth_user)
    assert @controller.send(:auth)
    assert @controller.instance_variable_defined?(:@auth_user)
  end

  test 'redirect to login function' do
    login_admin

    @controller.send(:redirect_to_login)
    assert_redirected_to login_users_path
  end

  test 'restart session function' do
    login_admin
    
    @controller.send(:session)[:session_test] = 'test'
    @controller.send(:flash)[:flash_test] = 'test'
    assert_not_nil @controller.send(:session)[:session_test]
    assert_not_nil @controller.send(:flash)[:flash_test]
    @controller.send(:restart_session)
    assert_nil @controller.send(:session)[:session_test]
    assert_not_nil @controller.send(:flash)[:flash_test]
  end

  private

  def login_admin
    assert @controller.send(:auth)
  end
end