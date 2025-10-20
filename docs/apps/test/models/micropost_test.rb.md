# test/models/micropost_test.rb

## Test Annotations

### TEST-micropost-validations-basics (line 10)
- id: TEST-micropost-validations-basics
- covers:
  ```json
  [
    "app/models/micropost.rb#Micropost"
  ]
  ```
- intent: Baseline micropost with user and content is valid
- kind: unit

### TEST-micropost-user-required (line 18)
- id: TEST-micropost-user-required
- covers:
  ```json
  [
    "app/models/micropost.rb#Micropost"
  ]
  ```
- intent: Micropost must belong to a user
- kind: unit

### TEST-micropost-content-presence (line 27)
- id: TEST-micropost-content-presence
- covers:
  ```json
  [
    "app/models/micropost.rb#Micropost"
  ]
  ```
- intent: Reject blank content
- kind: unit

### TEST-micropost-content-length (line 36)
- id: TEST-micropost-content-length
- covers:
  ```json
  [
    "app/models/micropost.rb#Micropost"
  ]
  ```
- intent: Enforce maximum length of 140 characters
- kind: unit

### TEST-micropost-default-scope-order (line 45)
- id: TEST-micropost-default-scope-order
- covers:
  ```json
  [
    "app/models/micropost.rb#Micropost"
  ]
  ```
- intent: Default scope returns newest micropost first
- kind: unit
