# app/models/relationship.rb

## Code Annotations

### app/models/relationship.rb#Relationship (line 1)
- id: app/models/relationship.rb#Relationship
- summary: Follow relationship join model between users
- intent: Persist follower-followed pairs and enforce presence of both sides
- contract:
  ```json
  {
    "requires": [
      "follower_id present",
      "followed_id present"
    ],
    "ensures": [
      "belongs_to associations resolve to User"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "attributes": "{follower: User, followed: User}"
    },
    "output": {
      "record": "Relationship"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordInvalid"
  ]
  ```
- sideEffects: Inserts/deletes rows in relationships table
- security: Authorization enforced at controller level
- perf: Simple presence validations; relies on DB indexes
- dependencies:
  ```json
  [
    "User",
    "ApplicationRecord"
  ]
  ```
- example:
  ```json
  {
    "ok": "users(:michael).active_relationships.create!(followed: users(:archer))",
    "ng": "Relationship.create!(follower:nil, followed:nil) # raises ActiveRecord::RecordInvalid"
  }
  ```
- cases:
  ```json
  [
    "TEST-relationship-validations-basics",
    "TEST-relationship-follower-required",
    "TEST-relationship-followed-required",
    "TEST-users-following-view",
    "TEST-users-followers-view",
    "TEST-user-follow-graph"
  ]
  ```
