# test/helpers/sessions_helper_test.rb

## Test Annotations

### TEST-sessions-helper-current-user (line 10)
- id: TEST-sessions-helper-current-user
- covers:
  ```json
  [
    "app/helpers/sessions_helper.rb#current_user",
    "app/helpers/sessions_helper.rb#remember"
  ]
  ```
- intent: current_user returns correct user when session is nil but remember cookie present
- kind: unit

### TEST-sessions-helper-invalid-remember (line 19)
- id: TEST-sessions-helper-invalid-remember
- covers:
  ```json
  [
    "app/helpers/sessions_helper.rb#current_user",
    "app/helpers/sessions_helper.rb#forget"
  ]
  ```
- intent: current_user returns nil when remember digest mismatches
- kind: unit
