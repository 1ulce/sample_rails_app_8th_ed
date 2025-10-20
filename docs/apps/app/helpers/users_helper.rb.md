# app/helpers/users_helper.rb

## Code Annotations

### app/helpers/users_helper.rb#UsersHelper (line 1)
- id: app/helpers/users_helper.rb#UsersHelper
- summary: View helpers for user presentation
- intent: Provide pure helpers shared across views
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "helpers return HTML-safe strings"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "view_context": "ActionView::Base"
    },
    "output": {
      "helpers": "String or ActiveSupport::SafeBuffer"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Ensure generated markup does not leak secrets
- perf: O(1)
- dependencies:
  ```json
  [
    "Digest::MD5",
    "image_tag"
  ]
  ```
- example:
  ```json
  {
    "ok": "gravatar_for(users(:michael))",
    "ng": "gravatar_for(nil) # raises NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-gravatar-helper"
  ]
  ```

### app/helpers/users_helper.rb#gravatar_for (line 15)
- id: app/helpers/users_helper.rb#gravatar_for
- summary: Build gravatar image tag for given user email
- intent: Render avatar thumbnails with configurable size
- contract:
  ```json
  {
    "requires": [
      "user responds to email and name"
    ],
    "ensures": [
      "returns image_tag HTML"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "user": "User",
      "options": "{size: Integer}"
    },
    "output": {
      "markup": "ActiveSupport::SafeBuffer"
    }
  }
  ```
- errors:
  ```json
  [
    "NoMethodError when user lacks email"
  ]
  ```
- sideEffects: none
- security: Uses HTTPS gravatar endpoint; does not expose raw email
- perf: MD5 hash computation O(length email)
- dependencies:
  ```json
  [
    "Digest::MD5",
    "image_tag"
  ]
  ```
- example:
  ```json
  {
    "ok": "gravatar_for(user, size: 40)",
    "ng": "gravatar_for(user, size: -1) # broken gravatar URL"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-gravatar-helper"
  ]
  ```
