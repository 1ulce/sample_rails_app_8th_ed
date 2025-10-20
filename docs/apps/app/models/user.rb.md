# app/models/user.rb

## Code Annotations

### app/models/user.rb#User (line 1)
- id: app/models/user.rb#User
- summary: User domain model for authentication, activation, and social graph features
- intent: Persist users with secure credentials and expose helpers for session, activation, reset, and follow relationships
- contract:
  ```json
  {
    "requires": [
      "valid name/email/password attributes for persistence"
    ],
    "ensures": [
      "remember/reset/activation digests stay consistent with tokens",
      "following links enforce referential integrity"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "attributes": "Hash-like params from controllers/jobs"
    },
    "output": {
      "record": "ActiveRecord::PersistenceResult"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordInvalid",
    "ActiveRecord::RecordNotFound"
  ]
  ```
- sideEffects: Touches users, microposts, relationships tables; triggers outbound email via UserMailer
- security: Hashes all sensitive tokens and enforces password validations; relies on controller filters for access control
- perf: AR validations O(1) per attribute; feed query O(n) by followers count with SQL include
- dependencies:
  ```json
  [
    "BCrypt::Password",
    "SecureRandom",
    "UserMailer",
    "Micropost",
    "Relationship",
    "ActiveRecord::Callbacks"
  ]
  ```
- example:
  ```json
  {
    "ok": "User.create!(name:\"Taro\", email:\"taro@example.jp\", password:\"foobar\", password_confirmation:\"foobar\")",
    "ng": "User.create!(name:\"\", email:\"invalid\", password:\"foo\", password_confirmation:\"bar\") # raises ActiveRecord::RecordInvalid"
  }
  ```
- cases:
  ```json
  [
    "TEST-user-validations-basics",
    "TEST-users-signup-activation-flow",
    "TEST-user-follow-graph",
    "TEST-user-feed-follows",
    "TEST-user-email-downcase",
    "TEST-password-reset-expiry"
  ]
  ```

### app/models/user.rb#User.digest (line 34)
- id: app/models/user.rb#User.digest
- summary: Generate a bcrypt digest for password-like secrets using environment-appropriate cost
- intent: Provide deterministic hashing for remember/reset tokens and fixtures
- contract:
  ```json
  {
    "requires": [
      "string.is_a?(String)",
      "string.present?"
    ],
    "ensures": [
      "returns bcrypt hash with configured cost"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "string": "String"
    },
    "output": {
      "digest": "String (bcrypt hash)"
    }
  }
  ```
- errors:
  ```json
  [
    "ArgumentError when string is nil"
  ]
  ```
- sideEffects: none
- security: Never log digests; relies on bcrypt cost tuning via ActiveModel::SecurePassword.min_cost
- perf: O(cost) bcrypt hashing (~100ms production, minimal in tests)
- dependencies:
  ```json
  [
    "BCrypt::Password",
    "ActiveModel::SecurePassword.min_cost"
  ]
  ```
- example:
  ```json
  {
    "ok": "User.digest(\"secret\") #=> \"$2a$12$...\"",
    "ng": "User.digest(nil) # ArgumentError"
  }
  ```
- cases:
  ```json
  [
  
  ]
  ```

### app/models/user.rb#User.new_token (line 52)
- id: app/models/user.rb#User.new_token
- summary: Generate a URL-safe random token for authentication flows
- intent: Issue unpredictable tokens for remember, activation, and reset digests
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "returns 22-char base64url token with ≥128 bits entropy"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "token": "String"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Uses SecureRandom.urlsafe_base64; safe for cookies/email links
- perf: O(1)
- dependencies:
  ```json
  [
    "SecureRandom"
  ]
  ```
- example:
  ```json
  {
    "ok": "User.new_token #=> \"d8C1O8l6o2hBvFSpJ6y7ZA\"",
    "ng": "(n/a)"
  }
  ```
- cases:
  ```json
  [
    "TEST-mailer-account-activation",
    "TEST-mailer-password-reset"
  ]
  ```

### app/models/user.rb#remember (line 68)
- id: app/models/user.rb#remember
- summary: Persist a remember digest so cookies can authenticate without credentials
- intent: Maintain long-lived session token hashed server-side
- contract:
  ```json
  {
    "requires": [
      "persisted? == true"
    ],
    "ensures": [
      "remember_digest stores bcrypt hash of new remember_token",
      "remember_token is accessible until overwritten"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "digest": "String"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::ActiveRecordError when update fails"
  ]
  ```
- sideEffects: Updates remember_digest column; mutates remember_token accessor
- security: Token never stored in DB; caller must guard cookie exposure
- perf: Single update SQL
- dependencies:
  ```json
  [
    "User.digest",
    "update_attribute"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.remember #=> \"$2a$12$...\" and sets remember_token",
    "ng": "User.new.remember # raises ActiveRecord::NotSaved"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie"
  ]
  ```

### app/models/user.rb#session_token (line 86)
- id: app/models/user.rb#session_token
- summary: Return the persisted remember digest, creating one if missing
- intent: Provide stable server-side token for verifying remember cookie
- contract:
  ```json
  {
    "requires": [
      "persisted? == true"
    ],
    "ensures": [
      "returns remember_digest",
      "creates remember_digest when absent"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "token": "String"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::ActiveRecordError when remember update fails"
  ]
  ```
- sideEffects: Calls remember when digest absent (DB write)
- security: Digest remains hashed; caller compares hashed value only
- perf: O(1) read with optional single update
- dependencies:
  ```json
  [
    "remember"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.session_token #=> \"$2a$12$...\"",
    "ng": "User.new.session_token # raises ActiveRecord::NotSaved"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie"
  ]
  ```

### app/models/user.rb#authenticated? (line 102)
- id: app/models/user.rb#authenticated?
- summary: Compare supplied token against stored digest attribute
- intent: Support multiple digest-backed flows (remember, activation, reset)
- contract:
  ```json
  {
    "requires": [
      "attribute corresponds to *_digest column"
    ],
    "ensures": [
      "returns true when token matches digest",
      "returns false when digest missing or mismatch"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "attribute": "String",
      "token": "String"
    },
    "output": {
      "authenticated": "Boolean"
    }
  }
  ```
- errors:
  ```json
  [
    "ArgumentError when attribute does not map to method"
  ]
  ```
- sideEffects: none
- security: Timing-safe bcrypt comparison; rejects nil digests up front
- perf: O(cost) bcrypt comparison
- dependencies:
  ```json
  [
    "BCrypt::Password",
    "send"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.authenticated?(:remember, token) #=> true when digest matches",
    "ng": "user.authenticated?(:remember, \"wrong\") #=> false"
  }
  ```
- cases:
  ```json
  [
    "TEST-user-authenticated-nil-digest",
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie",
    "TEST-users-signup-activation-flow",
    "TEST-users-signup-activation-blocked",
    "TEST-users-activation-invalid-token",
    "TEST-users-activation-invalid-email",
    "TEST-password-reset-token-validation"
  ]
  ```

### app/models/user.rb#forget (line 120)
- id: app/models/user.rb#forget
- summary: Clear the remember digest to invalidate persistent sessions
- intent: Force re-authentication after logout or credential reset
- contract:
  ```json
  {
    "requires": [
      "persisted? == true"
    ],
    "ensures": [
      "remember_digest becomes nil"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "result": "Boolean"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::ActiveRecordError when update fails"
  ]
  ```
- sideEffects: Updates remember_digest to nil
- security: Removes ability to reuse cookie-based login
- perf: Single update SQL
- dependencies:
  ```json
  [
    "update_attribute"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.forget #=> true and clears remember_digest",
    "ng": "User.new.forget # raises ActiveRecord::NotSaved"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-login-remember-cookie",
    "TEST-users-login-forget-cookie"
  ]
  ```

### app/models/user.rb#activate (line 136)
- id: app/models/user.rb#activate
- summary: Mark the user as activated and timestamp activation
- intent: Complete signup flow after valid email confirmation
- contract:
  ```json
  {
    "requires": [
      "persisted? == true"
    ],
    "ensures": [
      "activated == true",
      "activated_at set to Time.zone.now"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "result": "Boolean"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::ActiveRecordError when updates fail"
  ]
  ```
- sideEffects: Writes activated flag and timestamp
- security: Should only be called after token verification
- perf: Two update_attribute calls
- dependencies:
  ```json
  [
    "update_attribute",
    "Time.zone"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.activate #=> true and sets activated_at",
    "ng": "User.new.activate # raises ActiveRecord::NotSaved"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-signup-activation-success"
  ]
  ```

### app/models/user.rb#send_activation_email (line 153)
- id: app/models/user.rb#send_activation_email
- summary: Queue an immediate account activation email for the user
- intent: Deliver activation instructions after signup
- contract:
  ```json
  {
    "requires": [
      "activation_token present",
      "email present"
    ],
    "ensures": [
      "mail delivered via UserMailer.account_activation"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "delivery": "Mail::Message"
    }
  }
  ```
- errors:
  ```json
  [
    "Net::SMTPError when delivery fails"
  ]
  ```
- sideEffects: Enqueues synchronous email delivery
- security: Token embedded in email; ensure TLS when sending
- perf: Network-bound; synchronous deliver_now
- dependencies:
  ```json
  [
    "UserMailer.account_activation",
    "ActionMailer::DeliveryJob"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.send_activation_email #=> Mail::Message",
    "ng": "User.new.send_activation_email # raises NoMethodError on nil email"
  }
  ```
- cases:
  ```json
  [
    "TEST-mailer-account-activation",
    "TEST-users-signup-activation-flow",
    "TEST-users-signup-activation-success"
  ]
  ```

### app/models/user.rb#create_reset_digest (line 169)
- id: app/models/user.rb#create_reset_digest
- summary: Issue a fresh reset token and digest with timestamp for password recovery
- intent: Prepare user for password reset email workflow
- contract:
  ```json
  {
    "requires": [
      "persisted? == true"
    ],
    "ensures": [
      "reset_token accessor set",
      "reset_digest hashed from token",
      "reset_sent_at within current timestamp"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "token": "String"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::ActiveRecordError when update fails"
  ]
  ```
- sideEffects: Writes reset_digest and reset_sent_at; mutates reset_token
- security: Digest stored, token ephemeral; short expiry enforced by password_reset_expired?
- perf: Two update_attribute calls
- dependencies:
  ```json
  [
    "User.new_token",
    "User.digest",
    "Time.zone"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.create_reset_digest #=> token string",
    "ng": "User.new.create_reset_digest # raises ActiveRecord::NotSaved"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-request-updates",
    "TEST-mailer-password-reset"
  ]
  ```

### app/models/user.rb#send_password_reset_email (line 187)
- id: app/models/user.rb#send_password_reset_email
- summary: Send password reset instructions to the user
- intent: Deliver reset link after create_reset_digest
- contract:
  ```json
  {
    "requires": [
      "reset_token present",
      "email present"
    ],
    "ensures": [
      "mail delivered via UserMailer.password_reset"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "delivery": "Mail::Message"
    }
  }
  ```
- errors:
  ```json
  [
    "Net::SMTPError when delivery fails"
  ]
  ```
- sideEffects: Enqueues synchronous email delivery
- security: Reset token in email; short expiry enforced elsewhere
- perf: Network-bound; synchronous deliver_now
- dependencies:
  ```json
  [
    "UserMailer.password_reset"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.create_reset_digest && user.send_password_reset_email",
    "ng": "user.send_password_reset_email without digest # may email stale token"
  }
  ```
- cases:
  ```json
  [
    "TEST-mailer-password-reset",
    "TEST-password-reset-request-updates"
  ]
  ```

### app/models/user.rb#password_reset_expired? (line 203)
- id: app/models/user.rb#password_reset_expired?
- summary: Check whether reset token is older than two hours
- intent: Prevent reuse of stale password reset links
- contract:
  ```json
  {
    "requires": [
      "reset_sent_at present"
    ],
    "ensures": [
      "returns true when sent_at < 2 hours ago",
      "returns false otherwise"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "expired": "Boolean"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Enforces short-lived reset window
- perf: O(1)
- dependencies:
  ```json
  [
    "Time.zone"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.reset_sent_at = 3.hours.ago; user.password_reset_expired? #=> true",
    "ng": "user.reset_sent_at = 1.hour.ago; ... #=> false"
  }
  ```
- cases:
  ```json
  [
    "TEST-password-reset-expiry"
  ]
  ```

### app/models/user.rb#feed (line 219)
- id: app/models/user.rb#feed
- summary: Return microposts from the user and followed accounts
- intent: Provide timeline query with eager loading for UI
- contract:
  ```json
  {
    "requires": [
      "persisted? == true"
    ],
    "ensures": [
      "includes own microposts",
      "includes followed users' posts"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "relation": "ActiveRecord::Relation<Micropost>"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Builds SQL with subquery; no writes
- security: Scope restricted to accessible posts
- perf: Single query with subselect; relies on DB index on relationships
- dependencies:
  ```json
  [
    "Relationship",
    "Micropost.includes",
    "ActiveStorage"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.feed.where(user: user).exists?",
    "ng": "user.feed.where(user: unfollowed).exists? #=> false"
  }
  ```
- cases:
  ```json
  [
    "TEST-user-feed-follows"
  ]
  ```

### app/models/user.rb#follow (line 239)
- id: app/models/user.rb#follow
- summary: Create following relationship to another user
- intent: Allow social graph connections
- contract:
  ```json
  {
    "requires": [
      "other_user.is_a?(User)"
    ],
    "ensures": [
      "following includes other_user unless self"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "other_user": "User"
    },
    "output": {
      "relation": "Relationship"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordInvalid when validation fails"
  ]
  ```
- sideEffects: Inserts into relationships table
- security: Prevents self-follow at call site
- perf: Single insert
- dependencies:
  ```json
  [
    "active_relationships"
  ]
  ```
- example:
  ```json
  {
    "ok": "michael.follow(archer)",
    "ng": "michael.follow(michael) # no-op"
  }
  ```
- cases:
  ```json
  [
    "TEST-user-follow-graph"
  ]
  ```

### app/models/user.rb#unfollow (line 255)
- id: app/models/user.rb#unfollow
- summary: Remove following relationship to another user
- intent: Allow users to stop following others
- contract:
  ```json
  {
    "requires": [
      "other_user.is_a?(User)"
    ],
    "ensures": [
      "following no longer includes other_user"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "other_user": "User"
    },
    "output": {
      "result": "Relationship|nil"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Deletes from relationships join table
- security: Only affects current user's relationships
- perf: Single delete
- dependencies:
  ```json
  [
    "following"
  ]
  ```
- example:
  ```json
  {
    "ok": "michael.unfollow(archer)",
    "ng": "michael.unfollow(michael) # no-op"
  }
  ```
- cases:
  ```json
  [
    "TEST-user-follow-graph"
  ]
  ```

### app/models/user.rb#following? (line 271)
- id: app/models/user.rb#following?
- summary: Check whether current user follows the given user
- intent: Provide predicate for UI logic and policy checks
- contract:
  ```json
  {
    "requires": [
      "other_user.is_a?(User)"
    ],
    "ensures": [
      "returns true iff following includes other_user"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "other_user": "User"
    },
    "output": {
      "following": "Boolean"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Read-only; no sensitive output
- perf: Uses association cached collection (may hit DB first call)
- dependencies:
  ```json
  [
    "following"
  ]
  ```
- example:
  ```json
  {
    "ok": "michael.following?(archer) #=> true",
    "ng": "michael.following?(users(:malory)) #=> false"
  }
  ```
- cases:
  ```json
  [
    "TEST-user-follow-graph"
  ]
  ```

### app/models/user.rb#downcase_email (line 289)
- id: app/models/user.rb#downcase_email
- summary: Normalize email casing before persistence
- intent: Guarantee emails are stored lowercase for uniqueness
- contract:
  ```json
  {
    "requires": [
      "email present"
    ],
    "ensures": [
      "email equals email.downcase"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "email": "String"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Mutates self.email attribute
- security: Avoids case-sensitive duplicates; no PII leakage
- perf: O(length of email)
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "self.email = \"Foo@Bar.com\"; downcase_email; email == \"foo@bar.com\"",
    "ng": "self.email = nil; downcase_email # NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-user-email-downcase"
  ]
  ```

### app/models/user.rb#create_activation_digest (line 305)
- id: app/models/user.rb#create_activation_digest
- summary: Generate activation token and digest before user creation
- intent: Prepare new users for activation email workflow
- contract:
  ```json
  {
    "requires": [
      "new_record? == true"
    ],
    "ensures": [
      "activation_token accessor set",
      "activation_digest hashed from token"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "token": "String"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Mutates activation_token accessor; sets activation_digest attribute
- security: Digest stored; token ephemeral
- perf: O(1) with bcrypt hashing
- dependencies:
  ```json
  [
    "User.new_token",
    "User.digest"
  ]
  ```
- example:
  ```json
  {
    "ok": "user.send(:create_activation_digest) sets token/digest before save",
    "ng": "already persisted user callback rerun manually # resets digest unexpectedly"
  }
  ```
- cases:
  ```json
  [
    "TEST-users-signup-activation-flow",
    "TEST-users-activation-inactive-default"
  ]
  ```
