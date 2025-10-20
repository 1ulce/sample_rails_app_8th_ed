# config/routes.rb

## Code Annotations

### config/routes.rb#Routes (line 1)
- id: config/routes.rb#Routes
- summary: HTTP routing table for static pages, authentication, user management, and social features
- intent: Expose canonical paths for controllers while keeping URL semantics stable for UI and API clients
- contract:
  ```json
  {
    "requires": [
      "Rails.application.routes.draw context",
      "unique path helpers for session login/logout"
    ],
    "ensures": [
      "root directs to StaticPages#home",
      "named routes exist for help/about/contact",
      "REST resources defined for users, account activations, password resets, microposts, relationships",
      "legacy /microposts GET routes to home for pagination compatibility"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "request": "HTTP verb + path"
    },
    "output": {
      "dispatch": "controller#action per mapping"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Defines middleware dispatch table at boot
- security: Relies on controller-level before_action hooks (logged_in_user, admin_user, etc.)
- perf: Route set compiled at boot; minimal per-request overhead
- dependencies:
  ```json
  [
    "StaticPagesController",
    "UsersController",
    "SessionsController",
    "AccountActivationsController",
    "PasswordResetsController",
    "MicropostsController",
    "RelationshipsController"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /login -> SessionsController#new",
    "ng": "POST /logout -> no route (should use DELETE)"
  }
  ```
- cases:
  ```json
  [
    "TEST-static-home-route",
    "TEST-static-help-route",
    "TEST-static-about-route",
    "TEST-static-contact-route",
    "TEST-users-signup-invalid",
    "TEST-users-login-remember-cookie",
    "TEST-users-profile-feed",
    "TEST-microposts-interface-crud",
    "TEST-users-following-view"
  ]
  ```

### config/routes.rb#root (line 14)
- id: config/routes.rb#root
- summary: Root path shows the home feed or signup CTA
- intent: Default landing page for authenticated and guest users
- contract:
  ```json
  {
    "requires": [
      "root path lookup"
    ],
    "ensures": [
      "GET / dispatches to static_pages#home"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "GET",
      "path": "/"
    },
    "output": {
      "controller": "StaticPagesController",
      "action": "home"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Home controller handles conditional feed rendering
- perf: Static page render plus optional feed pagination
- dependencies:
  ```json
  [
    "StaticPagesController#home"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET / -> renders home",
    "ng": "POST / -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-static-home-route",
    "TEST-microposts-interface-crud"
  ]
  ```

### config/routes.rb#static_pages (line 28)
- id: config/routes.rb#static_pages
- summary: Named helpers for help/about/contact informational pages
- intent: Expose predictable URLs for marketing/navigation
- contract:
  ```json
  {
    "requires": [
      "GET requests"
    ],
    "ensures": [
      "/help maps to static_pages#help",
      "/about maps to static_pages#about",
      "/contact maps to static_pages#contact"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "GET",
      "path": "/help|/about|/contact"
    },
    "output": {
      "controller": "StaticPagesController",
      "action": "help|about|contact"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Public content
- perf: Static renders
- dependencies:
  ```json
  [
    "StaticPagesController"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /help -> StaticPagesController#help",
    "ng": "POST /help -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-static-help-route",
    "TEST-static-about-route",
    "TEST-static-contact-route"
  ]
  ```

### config/routes.rb#signup (line 44)
- id: config/routes.rb#signup
- summary: Signup form entry point
- intent: Expose friendly /signup path for UsersController#new
- contract:
  ```json
  {
    "requires": [
      "GET request"
    ],
    "ensures": [
      "/signup routes to users#new"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "GET",
      "path": "/signup"
    },
    "output": {
      "controller": "UsersController",
      "action": "new"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Public; actual create path handles validation
- perf: Form render
- dependencies:
  ```json
  [
    "UsersController#new"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /signup",
    "ng": "POST /signup -> no route (use POST /users)"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-signup-invalid"
  ]
  ```

### config/routes.rb#sessions (line 58)
- id: config/routes.rb#sessions
- summary: Named routes for login/logout cycle
- intent: Provide semantic paths for session management
- contract:
  ```json
  {
    "requires": [
      "GET /login to sessions#new",
      "POST /login to sessions#create",
      "DELETE /logout to sessions#destroy"
    ],
    "ensures": [
      "Only listed verbs available"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "GET|POST|DELETE",
      "path": "/login|/logout"
    },
    "output": {
      "controller": "SessionsController",
      "action": "new|create|destroy"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: None at routing level
- security: Controller enforces authentication and remember tokens
- perf: Minimal
- dependencies:
  ```json
  [
    "SessionsController"
  ]
  ```
- example:
  ```json
  {
    "ok": "DELETE /logout",
    "ng": "GET /logout -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie"
  ]
  ```

### config/routes.rb#users (line 74)
- id: config/routes.rb#users
- summary: RESTful users resource with member routes for social graph
- intent: Support CRUD on users plus following/followers lists
- contract:
  ```json
  {
    "requires": [
      "resourceful routes"
    ],
    "ensures": [
      "/users standard routes",
      "member GET /users/:id/following|followers to UsersController#following|followers"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "REST verbs",
      "path": "/users(...)"
    },
    "output": {
      "controller": "UsersController",
      "action": "index|show|new|create|edit|update|destroy|following|followers"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Defines 8 REST routes plus 2 member routes
- security: Controller filters enforce login/admin
- perf: Pagination for index/follow lists
- dependencies:
  ```json
  [
    "UsersController"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /users/1/followers",
    "ng": "POST /users/1/followers -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-index-auth",
    "TEST-users-index-admin-list",
    "TEST-users-followers-list",
    "TEST-users-following-view",
    "TEST-users-destroy-admin-only"
  ]
  ```

### config/routes.rb#account_activations (line 93)
- id: config/routes.rb#account_activations
- summary: Expose activation token edit endpoint
- intent: Allow users to activate accounts via emailed link
- contract:
  ```json
  {
    "requires": [
      "GET /account_activations/:id/edit"
    ],
    "ensures": [
      "dispatch to AccountActivationsController#edit only"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "GET",
      "path": "/account_activations/:id/edit"
    },
    "output": {
      "controller": "AccountActivationsController",
      "action": "edit"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: None at routing
- security: Controller validates token/email
- perf: O(1)
- dependencies:
  ```json
  [
    "AccountActivationsController#edit"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /account_activations/abc/edit",
    "ng": "POST /account_activations -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-signup-activation-success",
    "TEST-users-activation-invalid-token"
  ]
  ```

### config/routes.rb#password_resets (line 107)
- id: config/routes.rb#password_resets
- summary: Routes for password reset request and completion
- intent: Provide form endpoints for requesting and applying reset tokens
- contract:
  ```json
  {
    "requires": [
      "GET new",
      "POST create",
      "GET edit",
      "PATCH/PUT update"
    ],
    "ensures": [
      "only listed actions exposed"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "GET|POST|PATCH|PUT",
      "path": "/password_resets(...)"
    },
    "output": {
      "controller": "PasswordResetsController",
      "action": "new|create|edit|update"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: None
- security: Controller enforces token and expiry
- perf: O(1)
- dependencies:
  ```json
  [
    "PasswordResetsController"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /password_resets",
    "ng": "DELETE /password_resets/1 -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-request-updates",
    "TEST-password-reset-token-validation",
    "TEST-password-reset-expiry"
  ]
  ```

### config/routes.rb#microposts (line 121)
- id: config/routes.rb#microposts
- summary: Authenticated create/destroy routes for microposts
- intent: Allow posting and deleting status updates
- contract:
  ```json
  {
    "requires": [
      "POST /microposts -> create",
      "DELETE /microposts/:id -> destroy"
    ],
    "ensures": [
      "no index/show routes"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "POST|DELETE",
      "path": "/microposts"
    },
    "output": {
      "controller": "MicropostsController",
      "action": "create|destroy"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none at routing
- security: Controller ensures login and ownership
- perf: none
- dependencies:
  ```json
  [
    "MicropostsController"
  ]
  ```
- example:
  ```json
  {
    "ok": "DELETE /microposts/1",
    "ng": "GET /microposts/1 -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-microposts-create-auth",
    "TEST-microposts-destroy-ownership",
    "TEST-microposts-interface-crud"
  ]
  ```

### config/routes.rb#relationships (line 135)
- id: config/routes.rb#relationships
- summary: Routes for follow/unfollow actions
- intent: Enable creation and destruction of follow relationships
- contract:
  ```json
  {
    "requires": [
      "POST /relationships -> create",
      "DELETE /relationships/:id -> destroy"
    ],
    "ensures": [
      "no index/show routes"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "POST|DELETE",
      "path": "/relationships"
    },
    "output": {
      "controller": "RelationshipsController",
      "action": "create|destroy"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Controller checks logged-in user
- perf: none
- dependencies:
  ```json
  [
    "RelationshipsController"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /relationships",
    "ng": "GET /relationships -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-following-view",
    "TEST-users-followers-view",
    "TEST-user-follow-graph"
  ]
  ```

### config/routes.rb#microposts-index-redirect (line 149)
- id: config/routes.rb#microposts-index-redirect
- summary: Redirect legacy GET /microposts to home page
- intent: Preserve pagination links for Turbo/Hotwire flows
- contract:
  ```json
  {
    "requires": [
      "GET /microposts"
    ],
    "ensures": [
      "dispatch to StaticPages#home for compatibility"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "verb": "GET",
      "path": "/microposts"
    },
    "output": {
      "controller": "StaticPagesController",
      "action": "home"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Same as home route
- perf: none
- dependencies:
  ```json
  [
    "StaticPagesController#home"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /microposts -> home",
    "ng": "DELETE /microposts -> handled by resource route"
  }
  ```
- cases:
  ```json
  [
    "TEST-microposts-interface-crud"
  ]
  ```
