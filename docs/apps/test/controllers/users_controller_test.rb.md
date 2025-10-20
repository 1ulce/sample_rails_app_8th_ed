# test/controllers/users_controller_test.rb

## Test Annotations

### TEST-users-signup-form (line 11)
- id: TEST-users-signup-form
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#new"
  ]
  ```
- intent: Signup route renders successfully
- kind: integration

### TEST-users-index-auth (line 20)
- id: TEST-users-index-auth
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#index"
  ]
  ```
- intent: Unauthenticated users are redirected from index
- kind: integration

### TEST-users-edit-login-required (line 29)
- id: TEST-users-edit-login-required
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#edit"
  ]
  ```
- intent: Must log in before editing profile
- kind: integration

### TEST-users-update-login-required (line 39)
- id: TEST-users-update-login-required
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#update"
  ]
  ```
- intent: Update requires authentication
- kind: integration

### TEST-users-edit-wrong-user (line 50)
- id: TEST-users-edit-wrong-user
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#correct_user",
    "app/controllers/users_controller.rb#edit"
  ]
  ```
- intent: Wrong user cannot load edit form
- kind: integration

### TEST-users-update-wrong-user (line 61)
- id: TEST-users-update-wrong-user
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#correct_user",
    "app/controllers/users_controller.rb#update"
  ]
  ```
- intent: Wrong user cannot update profile
- kind: integration

### TEST-users-destroy-login-required (line 73)
- id: TEST-users-destroy-login-required
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#destroy"
  ]
  ```
- intent: Destroy requires authentication
- kind: integration

### TEST-users-destroy-admin-only (line 84)
- id: TEST-users-destroy-admin-only
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#destroy",
    "app/controllers/users_controller.rb#admin_user"
  ]
  ```
- intent: Non-admin destroy attempt is blocked
- kind: integration

### TEST-users-following-list (line 96)
- id: TEST-users-following-list
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#following"
  ]
  ```
- intent: Must be logged in to view following list
- kind: integration

### TEST-users-followers-list (line 105)
- id: TEST-users-followers-list
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#followers"
  ]
  ```
- intent: Must be logged in to view followers list
- kind: integration
