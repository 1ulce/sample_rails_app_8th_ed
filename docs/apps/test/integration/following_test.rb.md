# test/integration/following_test.rb

## Test Annotations

### TEST-users-following-view (line 14)
- id: TEST-users-following-view
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#following",
    "app/models/user.rb#follow",
    "app/models/user.rb#following?"
  ]
  ```
- intent: Following page lists followed users and links
- kind: integration

### TEST-users-followers-view (line 28)
- id: TEST-users-followers-view
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#followers"
  ]
  ```
- intent: Followers page lists follower users and links
- kind: integration
