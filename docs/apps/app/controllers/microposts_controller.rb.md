# app/controllers/microposts_controller.rb

## Code Annotations

### app/controllers/microposts_controller.rb#MicropostsController (line 1)
- id: app/controllers/microposts_controller.rb#MicropostsController
- summary: Manage creation and deletion of microposts for authenticated users
- intent: Expose minimal REST endpoints to post status updates and remove owned posts while enforcing access control
- contract:
  ```json
  {
    "requires": [
      "logged_in_user before_action"
    ],
    "ensures": [
      "create builds micropost for current_user",
      "destroy only removes posts owned by current user"
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
    "ActiveRecord::RecordInvalid",
    "ActiveRecord::RecordNotFound",
    "ActionController::ParameterMissing"
  ]
  ```
- sideEffects: Writes to microposts table, attaches ActiveStorage blobs, flashes messages
- security: Authenticated-only actions; ownership enforced in correct_user
- perf: Create includes optional image attach; feed reload limited via pagination
- dependencies:
  ```json
  [
    "Micropost",
    "logged_in_user",
    "correct_user",
    "current_user.feed",
    "ActiveStorage::Attached"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /microposts {content:\"Hello\"}",
    "ng": "DELETE /microposts/:id by other user # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-microposts-create-auth",
    "TEST-microposts-destroy-auth",
    "TEST-microposts-destroy-ownership",
    "TEST-microposts-interface-crud"
  ]
  ```

### app/controllers/microposts_controller.rb#create (line 17)
- id: app/controllers/microposts_controller.rb#create
- summary: Persist a new micropost for the signed-in user and refresh home feed
- intent: Handle form submissions with optional image upload
- contract:
  ```json
  {
    "requires": [
      "current_user present",
      "micropost_params includes content and optional image"
    ],
    "ensures": [
      "on success: micropost saved, redirect root",
      "on failure: render static_pages/home with feed items"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": "micropost_params"
    },
    "output": {
      "status": "302|422",
      "template": "redirect or static_pages/home"
    }
  }
  ```
- errors:
  ```json
  [
    "ActionController::ParameterMissing",
    "ActiveRecord::RecordInvalid",
    "ActiveStorage::IntegrityError"
  ]
  ```
- sideEffects: Creates Micropost record, attaches uploaded image, flashes success on success, populates @feed_items on failure
- security: Requires logged in user; content sanitized via Rails helpers
- perf: Single insert plus potential ActiveStorage attach
- dependencies:
  ```json
  [
    "current_user.microposts.build",
    "current_user.feed.paginate",
    "Micropost"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /microposts content:\"Hi\" -> redirect root",
    "ng": "POST /microposts while logged out -> redirected login"
  }
  ```
- cases:
  ```json
  [
    "TEST-microposts-create-auth",
    "TEST-microposts-interface-crud"
  ]
  ```

### app/controllers/microposts_controller.rb#destroy (line 41)
- id: app/controllers/microposts_controller.rb#destroy
- summary: Delete an owned micropost and redirect back to the referring page
- intent: Allow users to remove their posts while respecting referer fallback
- contract:
  ```json
  {
    "requires": [
      "correct_user before_action found micropost"
    ],
    "ensures": [
      "micropost destroyed",
      "redirect to referrer or root with 303"
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
      "redirect": "referrer or root"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound"
  ]
  ```
- sideEffects: Deletes Micropost record and associated attachments; flashes success
- security: Ownership enforced via correct_user
- perf: Single delete and optional ActiveStorage cleanup
- dependencies:
  ```json
  [
    "correct_user",
    "request.referrer",
    "Micropost"
  ]
  ```
- example:
  ```json
  {
    "ok": "DELETE /microposts/:id for own post -> redirect back",
    "ng": "DELETE /microposts/:id by other user -> redirected root"
  }
  ```
- cases:
  ```json
  [
    "TEST-microposts-destroy-auth",
    "TEST-microposts-destroy-ownership",
    "TEST-microposts-interface-crud"
  ]
  ```

### app/controllers/microposts_controller.rb#micropost_params (line 65)
- id: app/controllers/microposts_controller.rb#micropost_params
- summary: Permit micropost content and image parameters
- intent: Protect against mass assignment
- contract:
  ```json
  {
    "requires": [
      "params[:micropost] present"
    ],
    "ensures": [
      "returns permitted content and image keys only"
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
- security: Prevents malicious attribute injection
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
    "ok": "micropost_params #=> {content: \"Hi\"}",
    "ng": "params without :micropost -> raises ActionController::ParameterMissing"
  }
  ```
- cases:
  ```json
  [
    "TEST-microposts-interface-crud"
  ]
  ```

### app/controllers/microposts_controller.rb#correct_user (line 81)
- id: app/controllers/microposts_controller.rb#correct_user
- summary: Locate micropost belonging to current user or redirect
- intent: Enforce ownership before destructive actions
- contract:
  ```json
  {
    "requires": [
      "current_user present"
    ],
    "ensures": [
      "assigns @micropost when owned",
      "redirects to root with 303 when not found"
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
  
  ]
  ```
- sideEffects: Sets @micropost or redirects
- security: Prevents deleting posts from other users
- perf: Single lookup scoped to current_user
- dependencies:
  ```json
  [
    "current_user.microposts.find_by",
    "root_url"
  ]
  ```
- example:
  ```json
  {
    "ok": "correct_user finds own micropost",
    "ng": "correct_user on others' micropost -> redirect root"
  }
  ```
- cases:
  ```json
  [
    "TEST-microposts-destroy-ownership",
    "TEST-microposts-interface-crud"
  ]
  ```
