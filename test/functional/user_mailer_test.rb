require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'New user notification' do
    user = users(:admin)
    mail = UserMailer.new_user_notification(user, 12345)
    assert_equal 'Alta de usuario en COCTS', mail.subject
    assert_equal [user.email], mail.to
    assert_equal [ENV['EMAIL_ADDRESS']], mail.from
    assert_match "#{user.name}", mail.body.encoded

    assert_difference 'ActionMailer::Base.deliveries.size' do
      mail.deliver
    end
  end
end
