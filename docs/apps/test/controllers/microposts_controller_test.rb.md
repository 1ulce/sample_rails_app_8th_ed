# test/controllers/microposts_controller_test.rb

## Test Annotations

### TEST-microposts-create-auth (line 9)
- id: TEST-microposts-create-auth
- covers:
  ```json
  [
    "app/controllers/microposts_controller.rb#create"
  ]
  ```
- intent: Unauthenticated users cannot create microposts
- kind: integration

### TEST-microposts-destroy-auth (line 20)
- id: TEST-microposts-destroy-auth
- covers:
  ```json
  [
    "app/controllers/microposts_controller.rb#destroy"
  ]
  ```
- intent: Unauthenticated users cannot delete microposts
- kind: integration

### TEST-microposts-destroy-ownership (line 32)
- id: TEST-microposts-destroy-ownership
- covers:
  ```json
  [
    "app/controllers/microposts_controller.rb#destroy",
    "app/controllers/microposts_controller.rb#correct_user"
  ]
  ```
- intent: Users cannot delete microposts they do not own
- kind: integration
