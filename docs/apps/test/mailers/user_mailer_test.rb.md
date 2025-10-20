# test/mailers/user_mailer_test.rb

## Test Annotations

### TEST-mailer-account-activation (line 5)
- id: TEST-mailer-account-activation
- covers:
  ```json
  [
    "app/mailers/user_mailer.rb#account_activation",
    "app/models/user.rb#User.new_token"
  ]
  ```
- intent: Activation email contains correct metadata and token
- kind: unit

### TEST-mailer-password-reset (line 21)
- id: TEST-mailer-password-reset
- covers:
  ```json
  [
    "app/mailers/user_mailer.rb#password_reset",
    "app/models/user.rb#User.new_token"
  ]
  ```
- intent: Password reset email includes token and metadata
- kind: unit
