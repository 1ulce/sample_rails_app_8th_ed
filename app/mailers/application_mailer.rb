# @a:id "app/mailers/application_mailer.rb#ApplicationMailer"
# @a:summary "Base mailer configuration shared by transactional mailers"
# @a:intent "Provide default sender and layout for all emails"
# @a:contract {"requires":[],"ensures":["default from address applied","layout 'mailer' used unless overridden"]}
# @a:io {"input":{"mail":"ActionMailer message"},"output":{"mail":"Mail::Message"}}
# @a:errors []
# @a:sideEffects "Sets headers on outbound emails"
# @a:security "Default sender domain configured for SPF/DKIM"
# @a:perf "None"
# @a:dependencies ["ActionMailer::Base","app/views/layouts/mailer.html.erb"]
# @a:example {"ok":"class UserMailer < ApplicationMailer; end","ng":"ApplicationMailer.default nil # would break header expectations"}
# @a:cases ["TEST-mailer-account-activation","TEST-mailer-password-reset"]
class ApplicationMailer < ActionMailer::Base
  default from: "user@realdomain.com"
  layout "mailer"
end
