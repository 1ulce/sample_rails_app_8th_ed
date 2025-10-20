# app/controllers/account_activations_controller.rb

## Code Annotations

### app/controllers/account_activations_controller.rb#AccountActivationsController (line 1)
- id: app/controllers/account_activations_controller.rb#AccountActivationsController
- summary: Handle email-based account activation via secure tokens
- intent: Accept activation links, verify tokens, activate accounts, and log users in
- contract:
  ```json
  {
    "requires": [
      "email param",
      "id param as token"
    ],
    "ensures": [
      "valid unactivated user with matching token gets activated and logged in",
      "invalid token/email redirects with danger flash"
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
      "status": "302",
      "redirect": "user or root"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordNotFound when email missing"
  ]
  ```
- sideEffects: Updates user activation fields, logs user in, flashes messages
- security: Validates token via User#authenticated?, ensures user not already activated
- perf: Single user lookup and update
- dependencies:
  ```json
  [
    "User",
    "User#activate",
    "SessionsHelper#log_in"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /account_activations/:token/edit?email=john@example.com",
    "ng": "GET with wrong email -> redirect root"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-activation-inactive-default",
    "TEST-users-signup-activation-blocked",
    "TEST-users-activation-invalid-token",
    "TEST-users-activation-invalid-email",
    "TEST-users-signup-activation-success"
  ]
  ```

### app/controllers/account_activations_controller.rb#edit (line 15)
- id: app/controllers/account_activations_controller.rb#edit
- summary: Validate activation token and activate user
- intent: Complete signup flow after email confirmation
- contract:
  ```json
  {
    "requires": [
      "params[:email]",
      "params[:id]"
    ],
    "ensures": [
      "on success: user.activate, log_in user, flash success, redirect to profile",
      "on failure: flash danger and redirect root"
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
      "status": "302",
      "redirect": "user or root"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Updates user activation state, logs user in
- security: Protects against invalid or already-activated users
- perf: O(1)
- dependencies:
  ```json
  [
    "User.find_by",
    "User#activated?",
    "User#authenticated?",
    "User#activate",
    "log_in"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET edit_account_activation_path(valid_token,email:user.email)",
    "ng": "GET with invalid token -> redirect root"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-signup-activation-blocked",
    "TEST-users-activation-invalid-token",
    "TEST-users-activation-invalid-email",
    "TEST-users-signup-activation-success"
  ]
  ```
