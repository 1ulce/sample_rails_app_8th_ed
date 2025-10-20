# app/models/application_record.rb

## Code Annotations

### app/models/application_record.rb#ApplicationRecord (line 1)
- id: app/models/application_record.rb#ApplicationRecord
- summary: Base ActiveRecord model configuration for the application
- intent: Provide shared behaviour (abstract class) for all models
- contract:
  ```json
  {
    "requires": [
      "inherits from ActiveRecord::Base"
    ],
    "ensures": [
      "descendants share connection scope",
      "abstract class prevents direct instantiation"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "subclass": "Class inheriting from ApplicationRecord"
    },
    "output": {
      "model": "ActiveRecord::Base descendant"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Relies on per-model validations and callbacks
- perf: No additional overhead beyond ActiveRecord
- dependencies:
  ```json
  [
    "ActiveRecord::Base"
  ]
  ```
- example:
  ```json
  {
    "ok": "class Widget < ApplicationRecord; end",
    "ng": "ApplicationRecord.new # raises NotImplementedError"
  }
  ```
- cases:
  ```json
  [
    "TEST-user-validations-basics",
    "TEST-micropost-validations-basics",
    "TEST-relationship-validations-basics"
  ]
  ```
