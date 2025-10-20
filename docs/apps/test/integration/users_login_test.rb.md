# test/integration/users_login_test.rb

## Test Annotations

### TEST-users-login-remember-cookie (line 85)
- id: TEST-users-login-remember-cookie
- covers:
  ```json
  [
    "app/models/user.rb#remember",
    "app/models/user.rb#session_token",
    "app/models/user.rb#authenticated?"
  ]
  ```
- intent: Remember-me option persists cookie token
- kind: integration

### TEST-users-login-forget-cookie (line 94)
- id: TEST-users-login-forget-cookie
- covers:
  ```json
  [
    "app/models/user.rb#forget",
    "app/models/user.rb#remember"
  ]
  ```
- intent: Disable remember-me clears cookie token
- kind: integration
