# test/integration/password_resets_test.rb

## Test Annotations

### TEST-password-reset-new-form (line 12)
- id: TEST-password-reset-new-form
- covers:
  ```json
  [
    "app/controllers/password_resets_controller.rb#new",
    "config/routes.rb#password_resets"
  ]
  ```
- intent: Render password reset request form
- kind: integration

### TEST-password-reset-invalid-email (line 22)
- id: TEST-password-reset-invalid-email
- covers:
  ```json
  [
    "app/controllers/password_resets_controller.rb#create"
  ]
  ```
- intent: Submitting unknown email re-renders form with error
- kind: integration

### TEST-password-reset-request-updates (line 47)
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

### TEST-password-reset-form-wrong-email (line 58)
- id: TEST-password-reset-form-wrong-email
- covers:
  ```json
  [
    "app/controllers/password_resets_controller.rb#valid_user"
  ]
  ```
- intent: Reset link rejects requests missing matching email parameter
- kind: integration

### TEST-password-reset-form-inactive (line 67)
- id: TEST-password-reset-form-inactive
- covers:
  ```json
  [
    "app/controllers/password_resets_controller.rb#valid_user"
  ]
  ```
- intent: Inactive user cannot use reset link
- kind: integration

### TEST-password-reset-token-validation (line 78)
- id: TEST-password-reset-token-validation
- covers:
  ```json
  [
    "app/models/user.rb#authenticated?"
  ]
  ```
- intent: Reject reset when token does not match digest
- kind: integration

### TEST-password-reset-form-valid-token (line 87)
- id: TEST-password-reset-form-valid-token
- covers:
  ```json
  [
    "app/controllers/password_resets_controller.rb#edit",
    "app/controllers/password_resets_controller.rb#valid_user"
  ]
  ```
- intent: Valid token renders the reset form
- kind: integration

### TEST-password-update-invalid-confirmation (line 101)
- id: TEST-password-update-invalid-confirmation
- covers:
  ```json
  [
    "app/controllers/password_resets_controller.rb#update"
  ]
  ```
- intent: Mismatched confirmation re-renders edit form
- kind: integration

### TEST-password-update-empty (line 113)
- id: TEST-password-update-empty
- covers:
  ```json
  [
    "app/controllers/password_resets_controller.rb#update"
  ]
  ```
- intent: Empty password rejects update
- kind: integration

### TEST-password-update-success (line 125)
- id: TEST-password-update-success
- covers:
  ```json
  [
    "app/controllers/password_resets_controller.rb#update",
    "app/helpers/sessions_helper.rb#log_in"
  ]
  ```
- intent: Valid password resets account and logs user in
- kind: integration
