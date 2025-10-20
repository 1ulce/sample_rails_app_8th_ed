# @a:id "app/mailers/user_mailer.rb#UserMailer"
# @a:summary "Transactional emails for account activation and password reset"
# @a:intent "Deliver tokenized emails for onboarding and recovery"
# @a:contract {"requires":["user responds to email, name, activation/reset tokens"],"ensures":["mail objects with expected subject and recipients"]}
# @a:io {"input":{"user":"User"},"output":{"mail":"Mail::Message"}}
# @a:errors ["Net::SMTPError when delivery fails"]
# @a:sideEffects "Triggers SMTP delivery or enqueues job"
# @a:security "Tokens embedded in links; ensure TLS and sanitized HTML"
# @a:perf "Synchronous mail rendering O(template size)"
# @a:dependencies ["ApplicationMailer","ActionMailer::Base","app/views/user_mailer/*"]
# @a:example {"ok":"UserMailer.account_activation(user).deliver_now","ng":"UserMailer.account_activation(nil) # raises NoMethodError"}
# @a:cases ["TEST-mailer-account-activation","TEST-mailer-password-reset"]
class UserMailer < ApplicationMailer

  # @a:id "app/mailers/user_mailer.rb#account_activation"
  # @a:summary "Compose activation mail with token link"
  # @a:intent "Guide new users through email confirmation"
  # @a:contract {"requires":["user.activation_token present","user.email present"],"ensures":["mail.to == [user.email]","mail.subject == \"Account activation\""]}
  # @a:io {"input":{"user":"User"},"output":{"mail":"Mail::Message"}}
  # @a:errors ["NoMethodError when user is nil"]
  # @a:sideEffects "none aside from mail creation"
  # @a:security "Token link should be HTTPS; mail body must avoid leaking password"
  # @a:perf "Renders ERB template"
  # @a:dependencies ["mail","user_mailer/account_activation"]
  # @a:example {"ok":"UserMailer.account_activation(user).deliver_now","ng":"UserMailer.account_activation(user_without_token) # mail missing token"}
  # @a:cases ["TEST-mailer-account-activation","TEST-users-signup-activation-flow"]
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  # @a:id "app/mailers/user_mailer.rb#password_reset"
  # @a:summary "Compose password reset mail with reset token link"
  # @a:intent "Allow users to recover access securely"
  # @a:contract {"requires":["user.reset_token present","user.email present"],"ensures":["mail.to == [user.email]","mail.subject == \"Password reset\""]}
  # @a:io {"input":{"user":"User"},"output":{"mail":"Mail::Message"}}
  # @a:errors ["NoMethodError when user is nil"]
  # @a:sideEffects "none aside from mail creation"
  # @a:security "Token should expire soon; avoid PII beyond email/name"
  # @a:perf "Renders ERB template"
  # @a:dependencies ["mail","user_mailer/password_reset"]
  # @a:example {"ok":"UserMailer.password_reset(user).deliver_now","ng":"UserMailer.password_reset(user_without_token) # mail missing token"}
  # @a:cases ["TEST-mailer-password-reset","TEST-password-reset-request-updates"]
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
