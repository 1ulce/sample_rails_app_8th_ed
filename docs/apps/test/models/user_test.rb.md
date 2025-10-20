# test/models/user_test.rb

## Test Annotations

### TEST-user-validations-basics (line 10)
- id: TEST-user-validations-basics
- covers:
  ```json
  [
    "app/models/user.rb#User"
  ]
  ```
- intent: Baseline fixture validates with default attributes
- kind: unit

### TEST-user-name-presence (line 18)
- id: TEST-user-name-presence
- covers:
  ```json
  [
    "app/models/user.rb#User"
  ]
  ```
- intent: Reject missing name
- kind: unit

### TEST-user-email-presence (line 27)
- id: TEST-user-email-presence
- covers:
  ```json
  [
    "app/models/user.rb#User"
  ]
  ```
- intent: Reject missing email
- kind: unit

### TEST-user-authenticated-nil-digest (line 80)
- id: TEST-user-authenticated-nil-digest
- covers:
  ```json
  [
    "app/models/user.rb#authenticated?"
  ]
  ```
- intent: Ensure nil digest returns false without raising
- kind: unit

### TEST-user-email-downcase (line 88)
- id: TEST-user-email-downcase
- covers:
  ```json
  [
    "app/models/user.rb#downcase_email",
    "app/models/user.rb#User"
  ]
  ```
- intent: Emails persist in lowercase regardless of input casing
- kind: unit

### TEST-user-follow-graph (line 107)
- id: TEST-user-follow-graph
- covers:
  ```json
  [
    "app/models/user.rb#follow",
    "app/models/user.rb#unfollow",
    "app/models/user.rb#following?"
  ]
  ```
- intent: Follow relationships add/remove correctly and disallow self-follow
- kind: unit

### TEST-user-feed-follows (line 125)
- id: TEST-user-feed-follows
- covers:
  ```json
  [
    "app/models/user.rb#feed"
  ]
  ```
- intent: Feed contains self and followed posts but not unfollowed
- kind: unit

### TEST-password-reset-expiry (line 151)
- id: TEST-password-reset-expiry
- covers:
  ```json
  [
    "app/models/user.rb#password_reset_expired?"
  ]
  ```
- intent: Reset tokens expire after two hours
- kind: unit
