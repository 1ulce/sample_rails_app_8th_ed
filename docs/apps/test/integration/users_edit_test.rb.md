# test/integration/users_edit_test.rb

## Test Annotations

### TEST-users-update-validations (line 9)
- id: TEST-users-update-validations
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#edit",
    "app/controllers/users_controller.rb#update",
    "app/models/user.rb#User"
  ]
  ```
- intent: Invalid attributes re-render edit form
- kind: integration

### TEST-users-edit-authorization (line 25)
- id: TEST-users-edit-authorization
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#edit",
    "app/controllers/users_controller.rb#update"
  ]
  ```
- intent: Friendly forwarding allows owner to edit successfully
- kind: integration
