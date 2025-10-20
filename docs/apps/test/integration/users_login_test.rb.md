# test/integration/users_login_test.rb

## Test Annotations

### TEST-sessions-new-template (line 12)
- id: TEST-sessions-new-template
- covers:
  ```json
  [
    "app/controllers/sessions_controller.rb#new",
    "config/routes.rb#sessions"
  ]
  ```
- intent: Login page renders new session template
- kind: integration

### TEST-sessions-invalid-login (line 21)
- id: TEST-sessions-invalid-login
- covers:
  ```json
  [
    "app/controllers/sessions_controller.rb#create",
    "app/helpers/sessions_helper.rb#store_location"
  ]
  ```
- intent: Invalid credentials re-render login with flash and do not log in
- kind: integration

### TEST-sessions-valid-login (line 48)
- id: TEST-sessions-valid-login
- covers:
  ```json
  [
    "app/controllers/sessions_controller.rb#create",
    "app/helpers/sessions_helper.rb#log_in"
  ]
  ```
- intent: Successful login redirects to user profile
- kind: integration

### TEST-sessions-valid-login-nav (line 57)
- id: TEST-sessions-valid-login-nav
- covers:
  ```json
  [
    "app/controllers/sessions_controller.rb#create",
    "app/helpers/sessions_helper.rb#log_in",
    "app/helpers/sessions_helper.rb#log_out"
  ]
  ```
- intent: Navbar links update after login
- kind: integration

### TEST-sessions-logout-success (line 80)
- id: TEST-sessions-logout-success
- covers:
  ```json
  [
    "app/controllers/sessions_controller.rb#destroy",
    "app/helpers/sessions_helper.rb#log_out"
  ]
  ```
- intent: Logout clears session and redirects to home
- kind: integration

### TEST-sessions-logout-nav (line 90)
- id: TEST-sessions-logout-nav
- covers:
  ```json
  [
    "app/controllers/sessions_controller.rb#destroy",
    "app/helpers/sessions_helper.rb#log_out"
  ]
  ```
- intent: Navbar reflects logged-out state after logout
- kind: integration

### TEST-sessions-logout-idempotent (line 101)
- id: TEST-sessions-logout-idempotent
- covers:
  ```json
  [
    "app/controllers/sessions_controller.rb#destroy"
  ]
  ```
- intent: Second logout request remains safe and redirects home
- kind: integration

### TEST-users-login-remember-cookie (line 113)
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

### TEST-users-login-forget-cookie (line 122)
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
