# test/integration/users_profile_test.rb

## Test Annotations

### TEST-users-profile-feed (line 10)
- id: TEST-users-profile-feed
- covers:
  ```json
  [
    "app/controllers/users_controller.rb#show",
    "app/models/user.rb#feed",
    "app/helpers/users_helper.rb#gravatar_for"
  ]
  ```
- intent: Profile page renders user info and timeline
- kind: integration
