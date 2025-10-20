# test/integration/users_index_test.rb

## Test Annotations

### TEST-users-index-admin-list (line 10)
- id: TEST-users-index-admin-list
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#index",
    "app/controllers/users_controller.rb#destroy",
    "app/models/user.rb#User"
  ]
  ```
- intent: Admins see paginated list with delete links and can remove users
- kind: integration

### TEST-users-index-non-admin-no-delete (line 33)
- id: TEST-users-index-non-admin-no-delete
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#index"
  ]
  ```
- intent: Non-admins cannot see delete links
- kind: integration
