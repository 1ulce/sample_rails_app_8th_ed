# app/controllers/users_controller.rb

## Code Annotations

### app/controllers/users_controller.rb#UsersController (line 1)
- id: app/controllers/users_controller.rb#UsersController
- summary: Endpoints for user CRUD, follow lists, and access control
- intent: Expose HTML flows for listing, showing, editing, and destroying users with proper auth guards
- contract:
  ```json
  {
    "requires": [
      "logged_in_user before_action for protected routes"
    ],
    "ensures": [
      "non-admins cannot destroy users",
      "users can only edit/update themselves"
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
    "ActiveRecord::RecordNotFound",
    "ActionController::ParameterMissing"
  ]
  ```
- sideEffects: Reads/writes users table, flashes session data, triggers mailer on create
- security: Enforces login, ownership, and admin checks; relies on `current_user?` and `current_user` helpers
- perf: Pagination queries O(n) per page; follow lists load via association scopes
- dependencies:
  ```json
  [
    "User",
    "Micropost",
    "will_paginate",
    "current_user?",
    "logged_in_user"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /users?page=2",
    "ng": "DELETE /users/:id by non-admin # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-index-auth",
    "TEST-users-index-admin-list",
    "TEST-users-index-non-admin-no-delete",
    "TEST-users-profile-feed",
    "TEST-users-edit-authorization",
    "TEST-users-destroy-admin-only",
    "TEST-users-following-list",
    "TEST-users-following-view",
    "TEST-users-followers-list",
    "TEST-users-followers-view"
  ]
  ```

### app/controllers/users_controller.rb#index (line 19)
- id: app/controllers/users_controller.rb#index
- summary: List activated users with pagination
- intent: Provide admin/regular access to user directory
- contract:
  ```json
  {
    "requires": [
      "logged_in_user before_action"
    ],
    "ensures": [
      "assigns @users paginate result"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "page": "params[:page] String"
    },
    "output": {
      "status": "200",
      "template": "users/index"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Reads paginated users
- security: Requires authenticated session
- perf: Pagination query O(n) per page
- dependencies:
  ```json
  [
    "User.paginate"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /users?page=1",
    "ng": "Unauthenticated GET /users # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-index-auth",
    "TEST-users-index-admin-list",
    "TEST-users-index-non-admin-no-delete"
  ]
  ```

### app/controllers/users_controller.rb#show (line 35)
- id: app/controllers/users_controller.rb#show
- summary: Render user profile and paginated microposts
- intent: Display profile page with timeline
- contract:
  ```json
  {
    "requires": [
      "id param resolves to user"
    ],
    "ensures": [
      "assigns @user and @microposts"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "id": "params[:id]"
    },
    "output": {
      "status": "200",
      "template": "users/show"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound when id invalid"
  ]
  ```
- sideEffects: Reads microposts with pagination
- security: Accessible publicly for activated users
- perf: Paginated query plus includes
- dependencies:
  ```json
  [
    "User.find",
    "Micropost.paginate"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /users/1",
    "ng": "GET /users/9999 # raises ActiveRecord::RecordNotFound"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-profile-feed"
  ]
  ```

### app/controllers/users_controller.rb#new (line 52)
- id: app/controllers/users_controller.rb#new
- summary: Instantiate unsaved user for signup form
- intent: Render signup page
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "assigns @user = User.new"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "status": "200",
      "template": "users/new"
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
- perf: O(1)
- dependencies:
  ```json
  [
    "User.new"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /signup",
    "ng": "(n/a)"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-signup-invalid"
  ]
  ```

### app/controllers/users_controller.rb#create (line 68)
- id: app/controllers/users_controller.rb#create
- summary: Persist new user and trigger activation email
- intent: Handle signup submissions with optimistic activation flow
- contract:
  ```json
  {
    "requires": [
      "user_params with name,email,password,password_confirmation"
    ],
    "ensures": [
      "on success: user saved, activation email sent, redirect root",
      "on failure: re-render new with 422"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": "user_params"
    },
    "output": {
      "status": "302|422",
      "template": "redirect or users/new"
    }
  }
  ```
- errors:
  ```json
  [
    "ActionController::ParameterMissing when :user absent"
  ]
  ```
- sideEffects: Writes user, sends email, flashes info
- security: Relies on strong params; account remains inactive until activation
- perf: Single insert + email send
- dependencies:
  ```json
  [
    "UserMailer.account_activation",
    "User#send_activation_email"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /users valid payload",
    "ng": "POST /users missing email #=> 422"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-signup-invalid",
    "TEST-users-signup-activation-flow"
  ]
  ```

### app/controllers/users_controller.rb#edit (line 91)
- id: app/controllers/users_controller.rb#edit
- summary: Render edit profile form for current user
- intent: Allow users to update attributes
- contract:
  ```json
  {
    "requires": [
      "correct_user before_action"
    ],
    "ensures": [
      "assigns @user"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "id": "params[:id]"
    },
    "output": {
      "status": "200",
      "template": "users/edit"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound when id invalid"
  ]
  ```
- sideEffects: Reads user record
- security: Requires login and ownership check
- perf: O(1)
- dependencies:
  ```json
  [
    "User.find",
    "correct_user"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /users/1/edit when logged in as same user",
    "ng": "GET /users/1/edit by other user # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-edit-login-required",
    "TEST-users-edit-authorization",
    "TEST-users-edit-wrong-user"
  ]
  ```

### app/controllers/users_controller.rb#update (line 107)
- id: app/controllers/users_controller.rb#update
- summary: Persist profile changes for the current user
- intent: Apply permitted attribute updates with optimistic redirect
- contract:
  ```json
  {
    "requires": [
      "correct_user before_action",
      "user_params present"
    ],
    "ensures": [
      "on success: flash success, redirect to @user",
      "on failure: render edit 422"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": "user_params"
    },
    "output": {
      "status": "302|422",
      "template": "redirect or users/edit"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound",
    "ActionController::ParameterMissing"
  ]
  ```
- sideEffects: Writes users table; sets flash
- security: Only same user may update; admin privileges not required
- perf: Single update
- dependencies:
  ```json
  [
    "User.find",
    "correct_user"
  ]
  ```
- example:
  ```json
  {
    "ok": "PATCH /users/:id with valid data",
    "ng": "PATCH /users/:id by other user # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-update-login-required",
    "TEST-users-edit-authorization",
    "TEST-users-update-validations",
    "TEST-users-update-wrong-user"
  ]
  ```

### app/controllers/users_controller.rb#destroy (line 129)
- id: app/controllers/users_controller.rb#destroy
- summary: Delete user as admin-only action
- intent: Allow administrators to remove accounts
- contract:
  ```json
  {
    "requires": [
      "admin_user before_action"
    ],
    "ensures": [
      "user destroyed",
      "redirect to users_url with see_other"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "id": "params[:id]"
    },
    "output": {
      "status": "303",
      "redirect": "users_url"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound"
  ]
  ```
- sideEffects: Deletes user, cascades microposts/relationships
- security: Requires admin current_user
- perf: Single delete with dependent cleanup
- dependencies:
  ```json
  [
    "User.find",
    "admin_user"
  ]
  ```
- example:
  ```json
  {
    "ok": "DELETE /users/:id by admin",
    "ng": "DELETE /users/:id by regular user # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-destroy-login-required",
    "TEST-users-destroy-admin-only"
  ]
  ```

### app/controllers/users_controller.rb#following (line 147)
- id: app/controllers/users_controller.rb#following
- summary: Show paginated list of users the target user follows
- intent: Render follow relationships for UI
- contract:
  ```json
  {
    "requires": [
      "logged_in_user before_action"
    ],
    "ensures": [
      "assigns @user,@users,@title",
      "renders show_follow"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "id": "params[:id]"
    },
    "output": {
      "status": "422",
      "template": "users/show_follow"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound"
  ]
  ```
- sideEffects: Reads following association
- security: Requires login but not ownership
- perf: Paginated query on relationships join
- dependencies:
  ```json
  [
    "User.following",
    "paginate"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /users/:id/following",
    "ng": "GET /users/:id/following while logged out # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-following-list",
    "TEST-users-following-view"
  ]
  ```

### app/controllers/users_controller.rb#followers (line 166)
- id: app/controllers/users_controller.rb#followers
- summary: Show paginated list of users that follow the target user
- intent: Render followers panel
- contract:
  ```json
  {
    "requires": [
      "logged_in_user before_action"
    ],
    "ensures": [
      "assigns @user,@users,@title",
      "renders show_follow"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "id": "params[:id]"
    },
    "output": {
      "status": "422",
      "template": "users/show_follow"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound"
  ]
  ```
- sideEffects: Reads followers association
- security: Requires login
- perf: Paginated query on relationships join
- dependencies:
  ```json
  [
    "User.followers",
    "paginate"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /users/:id/followers",
    "ng": "GET /users/:id/followers while logged out # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-followers-list",
    "TEST-users-followers-view"
  ]
  ```

### app/controllers/users_controller.rb#user_params (line 187)
- id: app/controllers/users_controller.rb#user_params
- summary: Strong parameter whitelist for user attributes
- intent: Prevent mass-assignment of unsafe fields
- contract:
  ```json
  {
    "requires": [
      "params[:user] present"
    ],
    "ensures": [
      "returns permitted params for name,email,password,password_confirmation"
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
    "ActionController::ParameterMissing when :user absent"
  ]
  ```
- sideEffects: none
- security: Blocks role escalation; whitelist only safe fields
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
    "ok": "user_params #=> {name:..., email:...}",
    "ng": "params without :user # raises ActionController::ParameterMissing"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-signup-invalid",
    "TEST-users-update-validations"
  ]
  ```

### app/controllers/users_controller.rb#correct_user (line 206)
- id: app/controllers/users_controller.rb#correct_user
- summary: Redirect unless the requested user matches current_user
- intent: Enforce ownership for edit/update
- contract:
  ```json
  {
    "requires": [
      "logged_in_user already ran"
    ],
    "ensures": [
      "redirects to root with 303 when user mismatch",
      "assigns @user on success"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "id": "params[:id]"
    },
    "output": {
      "redirect_or_continue": "void"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound"
  ]
  ```
- sideEffects: Sets @user; may redirect via controller helper
- security: Prevents users from editing others' profiles
- perf: O(1)
- dependencies:
  ```json
  [
    "User.find",
    "current_user?",
    "root_url"
  ]
  ```
- example:
  ```json
  {
    "ok": "correct_user when ids match",
    "ng": "correct_user when mismatch # redirects root"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-edit-authorization",
    "TEST-users-edit-wrong-user",
    "TEST-users-update-wrong-user"
  ]
  ```

### app/controllers/users_controller.rb#admin_user (line 223)
- id: app/controllers/users_controller.rb#admin_user
- summary: Redirect unless current user has admin flag
- intent: Gate destructive actions to administrators
- contract:
  ```json
  {
    "requires": [
      "logged_in_user already ran"
    ],
    "ensures": [
      "redirects to root when current_user.admin? is false"
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
- sideEffects: none
- security: Blocks non-admin destroy attempts
- perf: O(1)
- dependencies:
  ```json
  [
    "current_user",
    "root_url"
  ]
  ```
- example:
  ```json
  {
    "ok": "admin_user when admin true",
    "ng": "admin_user when false # redirects root"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-destroy-login-required",
    "TEST-users-destroy-admin-only"
  ]
  ```
