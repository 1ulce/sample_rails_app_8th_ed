# app/helpers/application_helper.rb

## Code Annotations

### app/helpers/application_helper.rb#ApplicationHelper (line 1)
- id: app/helpers/application_helper.rb#ApplicationHelper
- summary: Global view helpers shared across layouts
- intent: Provide convenience methods like dynamic page titles
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "helpers return HTML-safe strings or primitives"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "view_context": "ActionView::Base"
    },
    "output": {
      "helpers": "String"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: No sensitive data exposure
- perf: O(1)
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "full_title(\"Help\") #=> \"Help | Ruby on Rails Tutorial Sample App\"",
    "ng": "full_title(nil) # raises NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-application-full-title"
  ]
  ```

### app/helpers/application_helper.rb#full_title (line 15)
- id: app/helpers/application_helper.rb#full_title
- summary: Compose full HTML title from base title and optional page segment
- intent: Avoid duplicate code for setting document titles
- contract:
  ```json
  {
    "requires": [
      "page_title optional string"
    ],
    "ensures": [
      "returns base title when blank",
      "returns \"{page} | {base}\" otherwise"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "page_title": "String"
    },
    "output": {
      "title": "String"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: No sensitive data
- perf: O(1)
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "full_title(\"Help\") #=> \"Help | Ruby on Rails Tutorial Sample App\"",
    "ng": "full_title(nil) # raises NoMethodError"
  }
  ```
- cases:
  ```json
  [
    "TEST-application-full-title",
    "TEST-users-profile-feed",
    "TEST-static-help-route"
  ]
  ```
