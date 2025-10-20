# test/controllers/relationships_controller_test.rb

## Test Annotations

### TEST-relationships-create-login-required (line 5)
- id: TEST-relationships-create-login-required
- covers:
  ```json
  [
    "app/controllers/relationships_controller.rb#create",
    "app/controllers/application_controller.rb#logged_in_user",
    "config/routes.rb#relationships"
  ]
  ```
- intent: Follow actions require authentication
- kind: integration

### TEST-relationships-destroy-login-required (line 16)
- id: TEST-relationships-destroy-login-required
- covers:
  ```json
  [
    "app/controllers/relationships_controller.rb#destroy",
    "app/controllers/application_controller.rb#logged_in_user",
    "config/routes.rb#relationships"
  ]
  ```
- intent: Unfollow actions require authentication
- kind: integration
