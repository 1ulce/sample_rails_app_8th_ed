# app/mailers/application_mailer.rb

## Code Annotations

### app/mailers/application_mailer.rb#ApplicationMailer (line 1)
- id: app/mailers/application_mailer.rb#ApplicationMailer
- summary: Base mailer configuration shared by transactional mailers
- intent: Provide default sender and layout for all emails
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "default from address applied",
      "layout 'mailer' used unless overridden"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "mail": "ActionMailer message"
    },
    "output": {
      "mail": "Mail::Message"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Sets headers on outbound emails
- security: Default sender domain configured for SPF/DKIM
- perf: None
- dependencies:
  ```json
  [
    "ActionMailer::Base",
    "app/views/layouts/mailer.html.erb"
  ]
  ```
- example:
  ```json
  {
    "ok": "class UserMailer < ApplicationMailer; end",
    "ng": "ApplicationMailer.default nil # would break header expectations"
  }
  ```
- cases:
  ```json
  [
    "TEST-mailer-account-activation",
    "TEST-mailer-password-reset"
  ]
  ```
