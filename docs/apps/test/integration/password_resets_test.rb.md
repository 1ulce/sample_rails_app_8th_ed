# test/integration/password_resets_test.rb

## Test Annotations

### TEST-password-reset-request-updates (line 39)
- id: TEST-password-reset-request-updates
- covers:
  ```json
  [
    "app/models/user.rb#create_reset_digest",
    "app/models/user.rb#send_password_reset_email"
  ]
  ```
- intent: Successful reset request rotates digest and sends mail
- kind: integration

### TEST-password-reset-token-validation (line 62)
- id: TEST-password-reset-token-validation
- covers:
  ```json
  [
    "app/models/user.rb#authenticated?"
  ]
  ```
- intent: Reject reset when token does not match digest
- kind: integration
