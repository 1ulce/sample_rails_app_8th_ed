# app/mailers/user_mailer.rb

## Code Annotations

### app/mailers/user_mailer.rb#UserMailer (line 1)
- id: app/mailers/user_mailer.rb#UserMailer
- summary: Transactional emails for account activation and password reset
- intent: Deliver tokenized emails for onboarding and recovery
- contract:
  ```json
  {
    "requires": [
      "user responds to email, name, activation/reset tokens"
    ],
    "ensures": [
      "mail objects with expected subject and recipients"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "user": "User"
    },
    "output": {
      "mail": "Mail::Message"
    }
  }
  ```
- errors:
  ```json
  [
    "Net::SMTPError when delivery fails"
  ]
  ```
- sideEffects: Triggers SMTP delivery or enqueues job
- security: Tokens embedded in links; ensure TLS and sanitized HTML
- perf: Synchronous mail rendering O(template size)
- dependencies:
  ```json
  [
    "ApplicationMailer",
    "ActionMailer::Base",
    "app/views/user_mailer/*"
  ]
  ```
- example:
  ```json
  {
    "ok": "UserMailer.account_activation(user).deliver_now",
    "ng": "UserMailer.account_activation(nil) # raises NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-mailer-account-activation",
    "TEST-mailer-password-reset"
  ]
  ```

### app/mailers/user_mailer.rb#account_activation (line 15)
- id: app/mailers/user_mailer.rb#account_activation
- summary: Compose activation mail with token link
- intent: Guide new users through email confirmation
- contract:
  ```json
  {
    "requires": [
      "user.activation_token present",
      "user.email present"
    ],
    "ensures": [
      "mail.to == [user.email]",
      "mail.subject == \"Account activation\""
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "user": "User"
    },
    "output": {
      "mail": "Mail::Message"
    }
  }
  ```
- errors:
  ```json
  [
    "NoMethodError when user is nil"
  ]
  ```
- sideEffects: none aside from mail creation
- security: Token link should be HTTPS; mail body must avoid leaking password
- perf: Renders ERB template
- dependencies:
  ```json
  [
    "mail",
    "user_mailer/account_activation"
  ]
  ```
- example:
  ```json
  {
    "ok": "UserMailer.account_activation(user).deliver_now",
    "ng": "UserMailer.account_activation(user_without_token) # mail missing token"
  }
  ```
- cases:
  ```json
  [
    "TEST-mailer-account-activation",
    "TEST-users-signup-activation-flow"
  ]
  ```

### app/mailers/user_mailer.rb#password_reset (line 32)
- id: app/mailers/user_mailer.rb#password_reset
- summary: Compose password reset mail with reset token link
- intent: Allow users to recover access securely
- contract:
  ```json
  {
    "requires": [
      "user.reset_token present",
      "user.email present"
    ],
    "ensures": [
      "mail.to == [user.email]",
      "mail.subject == \"Password reset\""
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "user": "User"
    },
    "output": {
      "mail": "Mail::Message"
    }
  }
  ```
- errors:
  ```json
  [
    "NoMethodError when user is nil"
  ]
  ```
- sideEffects: none aside from mail creation
- security: Token should expire soon; avoid PII beyond email/name
- perf: Renders ERB template
- dependencies:
  ```json
  [
    "mail",
    "user_mailer/password_reset"
  ]
  ```
- example:
  ```json
  {
    "ok": "UserMailer.password_reset(user).deliver_now",
    "ng": "UserMailer.password_reset(user_without_token) # mail missing token"
  }
  ```
- cases:
  ```json
  [
    "TEST-mailer-password-reset",
    "TEST-password-reset-request-updates"
  ]
  ```
