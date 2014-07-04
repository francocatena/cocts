ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/pride'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def perform_auth(user = users(:admin))
    temp_controller, @controller = @controller, UsersController.new

    post :create_session, :user => {:user => user.user, :password => user.password}
    assert_not_nil session[:user_id]
    auth_user = User.find(session[:user_id])
    assert_redirected_to projects_path
    assert_not_nil auth_user
    assert_equal user.user, auth_user.user

    @controller = temp_controller
  end

  def error_message_from_model(model, attribute, message, extra = {})
    ::ActiveModel::Errors.new(model).generate_message(attribute, message, extra)
  end
end
