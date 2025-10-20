# test/integration/microposts_interface_test.rb

## Test Annotations

### TEST-microposts-interface-crud (line 9)
- id: TEST-microposts-interface-crud
- covers:
  ```json
  [
    "app/controllers/microposts_controller.rb#create",
    "app/controllers/microposts_controller.rb#destroy",
    "app/controllers/microposts_controller.rb#micropost_params",
    "app/controllers/microposts_controller.rb#correct_user",
    "app/models/micropost.rb#Micropost"
  ]
  ```
- intent: Full micropost UI workflow covering invalid submissions, creation, deletion, and authorization
- kind: integration
