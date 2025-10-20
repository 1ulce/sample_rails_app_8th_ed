# test/models/relationship_test.rb

## Test Annotations

### TEST-relationship-validations-basics (line 10)
- id: TEST-relationship-validations-basics
- covers:
  ```json
  [
    "app/models/relationship.rb#Relationship"
  ]
  ```
- intent: Valid relationship with follower and followed users persists
- kind: unit

### TEST-relationship-follower-required (line 18)
- id: TEST-relationship-follower-required
- covers:
  ```json
  [
    "app/models/relationship.rb#Relationship"
  ]
  ```
- intent: Relationship requires follower_id
- kind: unit

### TEST-relationship-followed-required (line 27)
- id: TEST-relationship-followed-required
- covers:
  ```json
  [
    "app/models/relationship.rb#Relationship"
  ]
  ```
- intent: Relationship requires followed_id
- kind: unit
