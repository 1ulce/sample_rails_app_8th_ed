# test/integration/users_signup_test.rb

## Test Annotations

### TEST-users-signup-invalid (line 12)
- id: TEST-users-signup-invalid
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#create",
    "app/models/user.rb#User"
  ]
  ```
- intent: Reject invalid signup and re-render form
- kind: integration

### TEST-users-signup-activation-flow (line 29)
- id: TEST-users-signup-activation-flow
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#create",
    "app/models/user.rb#send_activation_email",
    "app/models/user.rb#create_activation_digest"
  ]
  ```
- intent: Successful signup sends activation email and keeps user pending
- kind: integration

### TEST-users-activation-inactive-default (line 55)
- id: TEST-users-activation-inactive-default
- covers:
  ```json
  [
    "app/models/user.rb#create_activation_digest",
    "app/models/user.rb#activate"
  ]
  ```
- intent: User remains inactive immediately after signup
- kind: integration

### TEST-users-signup-activation-blocked (line 63)
- id: TEST-users-signup-activation-blocked
- covers:
  ```json
  [
    "app/models/user.rb#authenticated?"
  ]
  ```
- intent: Login blocked until account activation completes
- kind: integration

### TEST-users-activation-invalid-token (line 72)
- id: TEST-users-activation-invalid-token
- covers:
  ```json
  [
    "app/models/user.rb#authenticated?"
  ]
  ```
- intent: Activation fails with invalid token
- kind: integration

### TEST-users-activation-invalid-email (line 81)
- id: TEST-users-activation-invalid-email
- covers:
  ```json
  [
    "app/models/user.rb#authenticated?"
  ]
  ```
- intent: Activation fails with incorrect email
- kind: integration

### TEST-users-signup-activation-success (line 90)
- id: TEST-users-signup-activation-success
- covers:
  ```json
  [
    "app/models/user.rb#activate",
    "app/models/user.rb#authenticated?"
  ]
  ```
- intent: Valid token activates account and logs in user
- kind: integration
