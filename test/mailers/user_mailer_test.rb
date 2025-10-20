require "test_helper"

class UserMailerTest < ActionMailer::TestCase

  # @t:id "TEST-mailer-account-activation"
  # @t:covers ["app/mailers/user_mailer.rb#account_activation","app/models/user.rb#User.new_token"]
  # @t:intent "Activation email contains correct metadata and token"
  # @t:kind "unit"
  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["user@realdomain.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

  # @t:id "TEST-mailer-password-reset"
  # @t:covers ["app/mailers/user_mailer.rb#password_reset","app/models/user.rb#User.new_token"]
  # @t:intent "Password reset email includes token and metadata"
  # @t:kind "unit"
  test "password_reset" do
    user = users(:michael)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["user@realdomain.com"], mail.from
    assert_match user.reset_token,        mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end
end
