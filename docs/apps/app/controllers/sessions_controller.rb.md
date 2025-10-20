# app/controllers/sessions_controller.rb

## Code Annotations

### app/controllers/sessions_controller.rb#SessionsController (line 1)
- id: app/controllers/sessions_controller.rb#SessionsController
- summary: Manage user session lifecycle (login/logout)
- intent: Provide form for credentials, authenticate users, handle remember-me cookies, and end sessions
- contract:
  ```json
  {
    "requires": [
      "SessionsHelper for authentication utilities"
    ],
    "ensures": [
      "new renders login form",
      "create authenticates and redirects or re-renders",
      "destroy logs out and redirects home"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": "ActionController::Parameters"
    },
    "output": {
      "response": "HTML"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound when email missing"
  ]
  ```
- sideEffects: Mutates session, cookies, flash messages
- security: Checks activation status, resets session to prevent fixation, handles remember token securely
- perf: Database lookup by email plus optional remember updates
- dependencies:
  ```json
  [
    "SessionsHelper",
    "User",
    "remember",
    "forget",
    "log_in",
    "log_out",
    "store_location"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /login with valid creds",
    "ng": "POST /login for inactive user -> warns and redirects"
  }
  ```
- cases:
  ```json
  [
    "TEST-sessions-new-route",
    "TEST-sessions-new-template",
    "TEST-sessions-invalid-login",
    "TEST-sessions-valid-login",
    "TEST-sessions-valid-login-nav",
    "TEST-users-signup-activation-blocked",
    "TEST-users-signup-activation-success",
    "TEST-sessions-logout-success",
    "TEST-sessions-logout-nav",
    "TEST-sessions-logout-idempotent",
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie"
  ]
  ```

### app/controllers/sessions_controller.rb#new (line 15)
- id: app/controllers/sessions_controller.rb#new
- summary: Render login form
- intent: Present fields for email/password
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "renders sessions/new template"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "status": "200",
      "template": "sessions/new"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: No sensitive data returned
- perf: Static render
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /login",
    "ng": "POST /login -> handled by create"
  }
  ```
- cases:
  ```json
  [
    "TEST-sessions-new-route",
    "TEST-sessions-new-template"
  ]
  ```

### app/controllers/sessions_controller.rb#create (line 30)
- id: app/controllers/sessions_controller.rb#create
- summary: Authenticate credentials and start a session
- intent: Handle login submissions with support for remember-me and activation checks
- contract:
  ```json
  {
    "requires": [
      "params[:session][:email]",
      "params[:session][:password]"
    ],
    "ensures": [
      "valid user with active account: resets session, optionally remembers, redirects to forwarding_url or profile",
      "inactive user: flashes warning and redirects home",
      "invalid credentials: re-renders new with 422"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": "session email/password, remember_me"
    },
    "output": {
      "status": "302|422",
      "redirect": "user|root",
      "template": "sessions/new on failure"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Updates session id, cookies, flash, resets stored forwarding url
- security: Downcases email, prevents session fixation, handles remember tokens securely, blocks unactivated accounts
- perf: Single user lookup and bcrypt authentication
- dependencies:
  ```json
  [
    "User.find_by",
    "authenticate",
    "remember",
    "forget",
    "log_in",
    "log_out",
    "store_location",
    "session"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /login valid creds -> redirect profile",
    "ng": "POST /login inactive account -> flash warning"
  }
  ```
- cases:
  ```json
  [
    "TEST-sessions-invalid-login",
    "TEST-sessions-valid-login",
    "TEST-sessions-valid-login-nav",
    "TEST-users-signup-activation-blocked",
    "TEST-users-signup-activation-success",
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie"
  ]
  ```

### app/controllers/sessions_controller.rb#destroy (line 63)
- id: app/controllers/sessions_controller.rb#destroy
- summary: End the current user session
- intent: Log out user safely and redirect home
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "log_out called if logged in",
      "redirects to root with see_other"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "status": "303",
      "redirect": "root_url"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Clears remember cookies and session
- security: Idempotent logout to prevent replay
- perf: O(1)
- dependencies:
  ```json
  [
    "log_out",
    "logged_in?",
    "reset_session"
  ]
  ```
- example:
  ```json
  {
    "ok": "DELETE /logout while logged in",
    "ng": "DELETE /logout while logged out -> still redirects home"
  }
  ```
- cases:
  ```json
  [
    "TEST-sessions-logout-success",
    "TEST-sessions-logout-nav",
    "TEST-sessions-logout-idempotent"
  ]
  ```
