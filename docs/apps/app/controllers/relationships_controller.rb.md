# app/controllers/relationships_controller.rb

## Code Annotations

### app/controllers/relationships_controller.rb#RelationshipsController (line 1)
- id: app/controllers/relationships_controller.rb#RelationshipsController
- summary: Handle follow/unfollow actions between users
- intent: Create and destroy relationship records with HTML and Turbo responses
- contract:
  ```json
  {
    "requires": [
      "logged_in_user before_action"
    ],
    "ensures": [
      "create follows target user",
      "destroy unfollows target user",
      "HTML responds with redirect, turbo renders stream templates"
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
      "response": "HTML or Turbo Stream"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound"
  ]
  ```
- sideEffects: Mutates relationships table, triggers broadcasts via Turbo templates
- security: Requires login; ownership enforced by using current_user for follow/unfollow
- perf: Single read/write operations
- dependencies:
  ```json
  [
    "User",
    "Relationship",
    "current_user.follow",
    "current_user.unfollow"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /relationships?followed_id=2",
    "ng": "DELETE /relationships/:id by non-owner before login # redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-relationships-create-login-required",
    "TEST-relationships-destroy-login-required",
    "TEST-users-following-view",
    "TEST-users-followers-view",
    "TEST-user-follow-graph"
  ]
  ```

### app/controllers/relationships_controller.rb#create (line 16)
- id: app/controllers/relationships_controller.rb#create
- summary: Follow another user and respond with redirect or turbo stream
- intent: Persist follow relationship initiated from UI
- contract:
  ```json
  {
    "requires": [
      "params[:followed_id] present"
    ],
    "ensures": [
      "current_user.follow(target)",
      "HTML redirect to target",
      "Turbo renders default stream"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "followed_id": "String"
    },
    "output": {
      "status": "302",
      "format": "html|turbo_stream"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound when user missing"
  ]
  ```
- sideEffects: Inserts Relationship row
- security: Uses current_user to prevent spoofing
- perf: Single insert
- dependencies:
  ```json
  [
    "User.find",
    "current_user.follow",
    "respond_to"
  ]
  ```
- example:
  ```json
  {
    "ok": "POST /relationships?followed_id=archer.id",
    "ng": "POST without login -> redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-relationships-create-login-required",
    "TEST-users-following-view",
    "TEST-user-follow-graph"
  ]
  ```

### app/controllers/relationships_controller.rb#destroy (line 37)
- id: app/controllers/relationships_controller.rb#destroy
- summary: Unfollow a user and respond with redirect or turbo stream
- intent: Remove existing relationship from UI actions
- contract:
  ```json
  {
    "requires": [
      "params[:id] corresponds to relationship current_user follows"
    ],
    "ensures": [
      "current_user.unfollow(target)",
      "HTML redirect with see_other",
      "Turbo renders default stream"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "id": "String"
    },
    "output": {
      "status": "303",
      "format": "html|turbo_stream"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound"
  ]
  ```
- sideEffects: Deletes Relationship row
- security: Only relationships involving current_user can be unfollowed
- perf: Single delete
- dependencies:
  ```json
  [
    "Relationship.find",
    "current_user.unfollow",
    "respond_to"
  ]
  ```
- example:
  ```json
  {
    "ok": "DELETE /relationships/:id belonging to current_user",
    "ng": "DELETE /relationships/:id while logged out -> redirected"
  }
  ```
- cases:
  ```json
  [
    "TEST-relationships-destroy-login-required",
    "TEST-users-followers-view",
    "TEST-user-follow-graph"
  ]
  ```
