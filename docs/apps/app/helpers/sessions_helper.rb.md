# app/helpers/sessions_helper.rb

## Code Annotations

### app/helpers/sessions_helper.rb#SessionsHelper (line 1)
- id: app/helpers/sessions_helper.rb#SessionsHelper
- summary: Session management helpers for authentication state
- intent: Encapsulate session, cookie, and current user logic for controllers and views
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "log_in stores user id and token",
      "remember persists cookie-based session",
      "current_user memoizes user",
      "log_out clears session and cookies",
      "store_location saves GET URLs"
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
      "session_state": "Mutated session/cookies"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Mutates session and cookies; memoizes @current_user
- security: Mitigates session fixation by storing session_token; encrypts cookies
- perf: O(1) operations
- dependencies:
  ```json
  [
    "User",
    "session",
    "cookies",
    "reset_session"
  ]
  ```
- example:
  ```json
  {
    "ok": "log_in(user) followed by current_user -> user",
    "ng": "remember(nil) # raises NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-sessions-valid-login",
    "TEST-sessions-valid-login-nav",
    "TEST-sessions-invalid-login",
    "TEST-sessions-logout-success",
    "TEST-sessions-logout-idempotent",
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie",
    "TEST-password-update-success",
    "TEST-users-edit-authorization",
    "TEST-users-update-validations",
    "TEST-users-following-view",
    "TEST-sessions-helper-current-user",
    "TEST-sessions-helper-invalid-remember"
  ]
  ```

### app/helpers/sessions_helper.rb#log_in (line 15)
- id: app/helpers/sessions_helper.rb#log_in
- summary: Persist session data for the authenticated user
- intent: Record user id and session token in Rails session storage
- contract:
  ```json
  {
    "requires": [
      "user responds to id and session_token"
    ],
    "ensures": [
      "session[:user_id] and session[:session_token] set"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "user": "User"
    },
    "output": {
      "session": "mutated"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Mutates session hash
- security: Stores session_token to detect hijacking
- perf: O(1)
- dependencies:
  ```json
  [
    "session"
  ]
  ```
- example:
  ```json
  {
    "ok": "log_in(user)",
    "ng": "log_in(nil) # raises NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-sessions-valid-login",
    "TEST-sessions-valid-login-nav",
    "TEST-password-update-success",
    "TEST-users-signup-activation-success"
  ]
  ```

### app/helpers/sessions_helper.rb#remember (line 34)
- id: app/helpers/sessions_helper.rb#remember
- summary: Set permanent cookies to keep a user logged in across sessions
- intent: Call User#remember and store encrypted identifiers in cookies
- contract:
  ```json
  {
    "requires": [
      "user responds to remember, remember_token, id"
    ],
    "ensures": [
      "permanent encrypted user_id cookie set",
      "permanent remember_token cookie set"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "user": "User"
    },
    "output": {
      "cookies": "mutated"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Writes persistent cookies
- security: Stores user_id encrypted, raw token stored separately for verification
- perf: O(1)
- dependencies:
  ```json
  [
    "user.remember",
    "cookies.permanent"
  ]
  ```
- example:
  ```json
  {
    "ok": "remember(user)",
    "ng": "remember(nil) # raises NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-login-remember-cookie",
    "TEST-sessions-valid-login"
  ]
  ```

### app/helpers/sessions_helper.rb#current_user (line 52)
- id: app/helpers/sessions_helper.rb#current_user
- summary: Retrieve and memoize the currently logged-in user
- intent: Check session, verify token, and lazy-load user object
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "returns User or nil",
      "memoizes @current_user when found",
      "verifies session token or remember cookie before setting"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "user": "User|nil"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: May call log_in when authenticating via remember cookie
- security: Compares session token to stored digest to prevent replay
- perf: Two lookups at most (session branch or cookie branch)
- dependencies:
  ```json
  [
    "session",
    "cookies",
    "User.find_by",
    "user.authenticated?",
    "remember"
  ]
  ```
- example:
  ```json
  {
    "ok": "current_user #=> logged in user",
    "ng": "current_user without session/cookie #=> nil"
  }
  ```
- cases:
  ```json
  [
    "TEST-sessions-valid-login",
    "TEST-sessions-valid-login-nav",
    "TEST-sessions-logout-success",
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie",
    "TEST-sessions-new-template",
    "TEST-sessions-invalid-login",
    "TEST-password-update-success"
  ]
  ```

### app/helpers/sessions_helper.rb#current_user? (line 79)
- id: app/helpers/sessions_helper.rb#current_user?
- summary: Check whether a given user matches the logged-in user
- intent: Provide convenient equality check for authorization
- contract:
  ```json
  {
    "requires": [
      "user may be nil"
    ],
    "ensures": [
      "returns true when provided user equals current_user"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "user": "User|nil"
    },
    "output": {
      "matches": "Boolean"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Used by controllers to gate editing
- perf: O(1)
- dependencies:
  ```json
  [
    "current_user"
  ]
  ```
- example:
  ```json
  {
    "ok": "current_user?(current_user) #=> true",
    "ng": "current_user?(nil) #=> false"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-edit-authorization",
    "TEST-users-update-wrong-user",
    "TEST-users-following-view"
  ]
  ```

### app/helpers/sessions_helper.rb#logged_in? (line 95)
- id: app/helpers/sessions_helper.rb#logged_in?
- summary: Boolean helper indicating session presence
- intent: Allow views/controllers to gate content based on login state
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "returns true iff current_user present"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "logged_in": "Boolean"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Used in before_action guards
- perf: Depends on current_user memoization
- dependencies:
  ```json
  [
    "current_user"
  ]
  ```
- example:
  ```json
  {
    "ok": "log_in(user); logged_in? #=> true",
    "ng": "reset_session; logged_in? #=> false"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-index-auth",
    "TEST-users-edit-login-required",
    "TEST-microposts-create-auth",
    "TEST-relationships-create-login-required",
    "TEST-sessions-logout-idempotent"
  ]
  ```

### app/helpers/sessions_helper.rb#forget (line 111)
- id: app/helpers/sessions_helper.rb#forget
- summary: Clear remember-me cookies for a user
- intent: Invalidate persistent login tokens
- contract:
  ```json
  {
    "requires": [
      "user responds to forget"
    ],
    "ensures": [
      "remember cookies removed"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "user": "User"
    },
    "output": {
      "cookies": "mutated"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Deletes cookies and resets user's remember digest
- security: Prevents stolen cookie reuse
- perf: O(1)
- dependencies:
  ```json
  [
    "user.forget",
    "cookies.delete"
  ]
  ```
- example:
  ```json
  {
    "ok": "forget(current_user)",
    "ng": "forget(nil) # raises"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-login-forget-cookie",
    "TEST-sessions-logout-success"
  ]
  ```

### app/helpers/sessions_helper.rb#log_out (line 129)
- id: app/helpers/sessions_helper.rb#log_out
- summary: Terminate session and forget persistent login
- intent: Log out user safely, clearing all session state
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "forget called with current_user",
      "session reset",
      "@current_user nil"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "session": "reset",
      "cookies": "cleared"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Mutates session and cookies
- security: Resets session id to prevent fixation
- perf: O(1)
- dependencies:
  ```json
  [
    "forget",
    "reset_session"
  ]
  ```
- example:
  ```json
  {
    "ok": "log_out",
    "ng": "log_out when current_user is nil -> no-op"
  }
  ```
- cases:
  ```json
  [
    "TEST-sessions-logout-success",
    "TEST-sessions-logout-idempotent",
    "TEST-sessions-logout-nav"
  ]
  ```

### app/helpers/sessions_helper.rb#store_location (line 147)
- id: app/helpers/sessions_helper.rb#store_location
- summary: Save intended URL to redirect after login
- intent: Enable friendly forwarding for GET requests
- contract:
  ```json
  {
    "requires": [
      "request available"
    ],
    "ensures": [
      "stores request.original_url in session[:forwarding_url] when GET"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "session": "mutated"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Writes session[:forwarding_url]
- security: Ignores non-GET requests to avoid CSRF vectors
- perf: O(1)
- dependencies:
  ```json
  [
    "session",
    "request"
  ]
  ```
- example:
  ```json
  {
    "ok": "store_location when GET /users/1/edit",
    "ng": "store_location on POST -> no change"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-edit-login-required",
    "TEST-users-update-login-required",
    "TEST-users-edit-authorization"
  ]
  ```
