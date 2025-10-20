# test/controllers/static_pages_controller_test.rb

## Test Annotations

### TEST-static-home-route (line 5)
- id: TEST-static-home-route
- covers:
  ```json
  [
    "config/routes.rb#root",
    "config/routes.rb#Routes"
  ]
  ```
- intent: Root path renders home page successfully
- kind: integration

### TEST-static-help-route (line 15)
- id: TEST-static-help-route
- covers:
  ```json
  [
    "config/routes.rb#static_pages",
    "config/routes.rb#Routes"
  ]
  ```
- intent: Help path resolves and renders expected title
- kind: integration

### TEST-static-about-route (line 25)
- id: TEST-static-about-route
- covers:
  ```json
  [
    "config/routes.rb#static_pages",
    "config/routes.rb#Routes"
  ]
  ```
- intent: About path resolves and renders expected title
- kind: integration

### TEST-static-contact-route (line 35)
- id: TEST-static-contact-route
- covers:
  ```json
  [
    "config/routes.rb#static_pages",
    "config/routes.rb#Routes"
  ]
  ```
- intent: Contact path resolves and renders expected title
- kind: integration
