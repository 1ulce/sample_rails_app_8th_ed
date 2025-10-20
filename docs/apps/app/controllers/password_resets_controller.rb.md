# app/controllers/password_resets_controller.rb

## Code Annotations

### app/controllers/password_resets_controller.rb#PasswordResetsController (line 1)
- id: app/controllers/password_resets_controller.rb#PasswordResetsController
- summary: Manage password reset requests, token validation, and credential updates
- intent: Allow users to request reset emails, validate tokens, and set new passwords securely
- contract:
  ```json
  {
    "requires": [
      "before_actions get_user, valid_user, check_expiration for edit/update"
    ],
    "ensures": [
      "new renders form",
      "create sends email or re-renders",
      "edit ensures valid token",
      "update enforces password presence and logs user in on success"
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
    "ActiveRecord::RecordNotFound when email missing in token steps"
  ]
  ```
- sideEffects: Sends emails, updates user reset digests, mutates session and flash
- security: Downcases email, validates activation, checks token expiry, prevents empty passwords
- perf: Single user lookup per action plus bcrypt updates
- dependencies:
  ```json
  [
    "User",
    "SessionsHelper#log_in",
    "UserMailer",
    "Time.zone"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /password_resets with email",
    "ng": "PATCH /password_reset/:id with empty password -> re-render"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-new-form",
    "TEST-password-reset-invalid-email",
    "TEST-password-reset-request-updates",
    "TEST-password-reset-form-wrong-email",
    "TEST-password-reset-form-inactive",
    "TEST-password-reset-token-validation",
    "TEST-password-reset-form-valid-token",
    "TEST-password-update-invalid-confirmation",
    "TEST-password-update-empty",
    "TEST-password-update-success",
    "TEST-password-reset-expiry"
  ]
  ```

### app/controllers/password_resets_controller.rb#new (line 18)
- id: app/controllers/password_resets_controller.rb#new
- summary: Render password reset request form
- intent: Provide UI for submitting email address
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "renders password_resets/new template"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "status": "200",
      "template": "password_resets/new"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Public route
- perf: Static render
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /password_resets/new",
    "ng": "POST /password_resets/new -> not routed"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-new-form"
  ]
  ```

### app/controllers/password_resets_controller.rb#create (line 33)
- id: app/controllers/password_resets_controller.rb#create
- summary: Process reset requests and send reset instructions
- intent: Lookup user by email, create reset digest, deliver mail, or re-render on failure
- contract:
  ```json
  {
    "requires": [
      "params[:password_reset][:email]"
    ],
    "ensures": [
      "valid email: create_reset_digest, send_password_reset_email, flash info, redirect root",
      "invalid email: flash danger, render new with 422"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "email": "String"
    },
    "output": {
      "status": "302|422",
      "redirect": "root_url"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Writes reset digest/timestamp, sends email
- security: Downcases email to prevent case bypass
- perf: Single user lookup plus digest hashing
- dependencies:
  ```json
  [
    "User.find_by",
    "User#create_reset_digest",
    "User#send_password_reset_email",
    "flash"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /password_resets email:user@example.com",
    "ng": "POST unknown email -> re-render"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-invalid-email",
    "TEST-password-reset-request-updates"
  ]
  ```

### app/controllers/password_resets_controller.rb#edit (line 58)
- id: app/controllers/password_resets_controller.rb#edit
- summary: Display form to enter new password
- intent: Allow users with valid token to set a new password
- contract:
  ```json
  {
    "requires": [
      "before_actions succeed"
    ],
    "ensures": [
      "renders password_resets/edit"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": {
        "email": "String",
        "id": "token"
      }
    },
    "output": {
      "status": "200",
      "template": "password_resets/edit"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Relies on valid_user and check_expiration
- perf: Static render
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "GET edit_password_reset_path(token,email)",
    "ng": "invalid token -> redirected before render"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-form-valid-token"
  ]
  ```

### app/controllers/password_resets_controller.rb#update (line 73)
- id: app/controllers/password_resets_controller.rb#update
- summary: Apply submitted password changes
- intent: Validate new password, update credentials, log user in, or re-render with errors
- contract:
  ```json
  {
    "requires": [
      "params[:user] with password/password_confirmation"
    ],
    "ensures": [
      "empty password adds error, renders edit 422",
      "valid update resets session, logs in user, flashes success, redirects profile",
      "other validation failures re-render edit 422"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": {
        "user": {
          "password": "String",
          "password_confirmation": "String"
        }
      }
    },
    "output": {
      "status": "302|422",
      "redirect": "@user"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Mutates password digest, resets session id, flashes success
- security: Prevents blank password, logs in user securely
- perf: Bcrypt hashing cost
- dependencies:
  ```json
  [
    "user_params",
    "@user.update",
    "reset_session",
    "log_in",
    "flash"
  ]
  ```
- example:
  ```json
  {
    "ok": "PATCH password_reset_path(token) with valid password",
    "ng": "PATCH with empty password -> re-render and error"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-update-invalid-confirmation",
    "TEST-password-update-empty",
    "TEST-password-update-success"
  ]
  ```

### app/controllers/password_resets_controller.rb#user_params (line 101)
- id: app/controllers/password_resets_controller.rb#user_params
- summary: Strong parameters for password update
- intent: Permit only password fields during update
- contract:
  ```json
  {
    "requires": [
      "params[:user] present"
    ],
    "ensures": [
      "returns permitted password attributes"
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
      "permitted": "ActionController::Parameters"
    }
  }
  ```
- errors:
  ```json
  [
    "ActionController::ParameterMissing"
  ]
  ```
- sideEffects: none
- security: Prevents mass assignment
- perf: O(1)
- dependencies:
  ```json
  [
    "params.require",
    "permit"
  ]
  ```
- example:
  ```json
  {
    "ok": "user_params -> {password:\"secret\"}",
    "ng": "params without :user -> raises"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-update-invalid-confirmation",
    "TEST-password-update-empty",
    "TEST-password-update-success"
  ]
  ```

### app/controllers/password_resets_controller.rb#get_user (line 119)
- id: app/controllers/password_resets_controller.rb#get_user
- summary: Lookup user by email for token actions
- intent: Assign @user used by edit/update filters
- contract:
  ```json
  {
    "requires": [
      "params[:email]"
    ],
    "ensures": [
      "@user assigned to matching user or nil"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": {
        "email": "String"
      }
    },
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
- sideEffects: Assigns instance variable
- security: Delegates verification to valid_user
- perf: Single lookup
- dependencies:
  ```json
  [
    "User.find_by"
  ]
  ```
- example:
  ```json
  {
    "ok": "get_user assigns existing user",
    "ng": "get_user when email missing -> @user nil"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-form-wrong-email",
    "TEST-password-reset-form-inactive",
    "TEST-password-reset-form-valid-token",
    "TEST-password-update-success"
  ]
  ```

### app/controllers/password_resets_controller.rb#valid_user (line 136)
- id: app/controllers/password_resets_controller.rb#valid_user
- summary: Ensure reset link belongs to an activated user with correct token
- intent: Block invalid token usage before editing password
- contract:
  ```json
  {
    "requires": [
      "@user assigned"
    ],
    "ensures": [
      "redirect root when user missing, inactive, or token mismatch"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": {
        "id": "token"
      }
    },
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
- sideEffects: Redirects to root when invalid
- security: Prevents unauthorized reset attempts
- perf: O(1)
- dependencies:
  ```json
  [
    "@user.activated?",
    "@user.authenticated?",
    "redirect_to"
  ]
  ```
- example:
  ```json
  {
    "ok": "valid token -> continue",
    "ng": "invalid token -> redirect root"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-form-wrong-email",
    "TEST-password-reset-form-inactive",
    "TEST-password-reset-token-validation",
    "TEST-password-reset-form-valid-token"
  ]
  ```

### app/controllers/password_resets_controller.rb#check_expiration (line 156)
- id: app/controllers/password_resets_controller.rb#check_expiration
- summary: Reject reset attempts when token is older than expiry window
- intent: Protect against stale reset tokens
- contract:
  ```json
  {
    "requires": [
      "@user assigned"
    ],
    "ensures": [
      "redirects to new password reset when expired",
      "allows flow when recent"
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
- sideEffects: Sets flash danger and redirects on expiry
- security: Forces user to restart reset flow
- perf: O(1)
- dependencies:
  ```json
  [
    "@user.password_reset_expired?",
    "flash",
    "redirect_to"
  ]
  ```
- example:
  ```json
  {
    "ok": "expired -> redirect new_password_reset_url",
    "ng": "fresh -> continue"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-expiry",
    "TEST-password-reset-request-updates"
  ]
  ```
