# app/controllers/application_controller.rb

## Code Annotations

### app/controllers/application_controller.rb#ApplicationController (line 1)
- id: app/controllers/application_controller.rb#ApplicationController
- summary: Global controller base with session helpers and authentication guard
- intent: Provide cross-cutting helpers and filters for downstream controllers
- contract:
  ```json
  {
    "requires": [
      "include SessionsHelper"
    ],
    "ensures": [
      "logged_in_user filter available to enforce access control"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "request": "ActionDispatch::Request"
    },
    "output": {
      "response": "ActionDispatch::Response"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Manages flash state and redirects during authentication checks
- security: Centralizes login enforcement via SessionsHelper
- perf: Minimal
- dependencies:
  ```json
  [
    "SessionsHelper",
    "flash",
    "redirect_to"
  ]
  ```
- example:
  ```json
  {
    "ok": "before_action :logged_in_user",
    "ng": "calling logged_in_user without SessionsHelper including logged_in? # raises NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-index-auth",
    "TEST-users-edit-login-required",
    "TEST-users-update-login-required",
    "TEST-users-destroy-login-required",
    "TEST-microposts-create-auth",
    "TEST-microposts-destroy-auth",
    "TEST-relationships-create-login-required",
    "TEST-relationships-destroy-login-required",
    "TEST-users-following-list",
    "TEST-users-followers-list"
  ]
  ```

### app/controllers/application_controller.rb#logged_in_user (line 18)
- id: app/controllers/application_controller.rb#logged_in_user
- summary: Redirect unauthenticated requests to the login page
- intent: Ensure protected routes can only be accessed by signed-in users
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "when logged_in? false: sets flash, stores requested URL, redirects login_url with 303",
      "when logged_in? true: no redirect"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "redirect_or_continue": "void"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Stores forwarding URL, mutates flash, triggers redirect
- security: Prevents unauthorized access to member-only pages
- perf: O(1)
- dependencies:
  ```json
  [
    "logged_in?",
    "store_location",
    "flash",
    "redirect_to",
    "login_url"
  ]
  ```
- example:
  ```json
  {
    "ok": "logged_in_user when logged out -> redirect to login",
    "ng": "logged_in_user when logged in -> no redirect"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-index-auth",
    "TEST-users-edit-login-required",
    "TEST-users-update-login-required",
    "TEST-users-destroy-login-required",
    "TEST-microposts-create-auth",
    "TEST-microposts-destroy-auth",
    "TEST-relationships-create-login-required",
    "TEST-relationships-destroy-login-required",
    "TEST-users-following-list",
    "TEST-users-followers-list"
  ]
  ```
