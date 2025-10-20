# app/controllers/static_pages_controller.rb

## Code Annotations

### app/controllers/static_pages_controller.rb#StaticPagesController (line 1)
- id: app/controllers/static_pages_controller.rb#StaticPagesController
- summary: Render static marketing pages and the home feed
- intent: Serve publicly accessible pages plus authenticated home timeline
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "home assigns feed data when logged in",
      "help/about/contact render respective templates"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "request": "ActionDispatch::Request"
    },
    "output": {
      "response": "HTML"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Reads current_user feed for home page
- security: Home leverages SessionsHelper to conditionally render feed
- perf: Feed pagination query executed only when logged in
- dependencies:
  ```json
  [
    "current_user",
    "Micropost",
    "paginate"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET / -> home with feed for logged-in user",
    "ng": "PATCH /help -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-static-home-route",
    "TEST-static-help-route",
    "TEST-static-about-route",
    "TEST-static-contact-route",
    "TEST-microposts-interface-crud",
    "TEST-users-profile-feed"
  ]
  ```

### app/controllers/static_pages_controller.rb#home (line 15)
- id: app/controllers/static_pages_controller.rb#home
- summary: Render home page and bootstrap feed for logged-in users
- intent: Show signup CTA to guests and micropost feed to members
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "assigns @micropost and @feed_items when logged_in?",
      "does not assign feed objects for guests"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "params": {
        "page": "String?"
      }
    },
    "output": {
      "status": "200",
      "template": "static_pages/home"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: Reads current_user feed; instantiates unsaved micropost
- security: Depends on logged_in? to expose user-specific data
- perf: Feed pagination query with includes (same as User#feed)
- dependencies:
  ```json
  [
    "logged_in?",
    "current_user.microposts.build",
    "current_user.feed.paginate"
  ]
  ```
- example:
  ```json
  {
    "ok": "GET home when logged in -> feed populated",
    "ng": "GET home when logged out -> no @feed_items"
  }
  ```
- cases:
  ```json
  [
    "TEST-static-home-route",
    "TEST-microposts-interface-crud"
  ]
  ```

### app/controllers/static_pages_controller.rb#help (line 34)
- id: app/controllers/static_pages_controller.rb#help
- summary: Render help page
- intent: Provide documentation/FAQ content
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "renders static_pages/help template"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "status": "200",
      "template": "static_pages/help"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Public
- perf: Static render
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /help",
    "ng": "POST /help -> not routed"
  }
  ```
- cases:
  ```json
  [
    "TEST-static-help-route"
  ]
  ```

### app/controllers/static_pages_controller.rb#about (line 49)
- id: app/controllers/static_pages_controller.rb#about
- summary: Render about page
- intent: Share project background
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "renders static_pages/about template"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "status": "200",
      "template": "static_pages/about"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Public
- perf: Static render
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /about",
    "ng": "POST /about -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-static-about-route"
  ]
  ```

### app/controllers/static_pages_controller.rb#contact (line 64)
- id: app/controllers/static_pages_controller.rb#contact
- summary: Render contact page
- intent: Expose contact information
- contract:
  ```json
  {
    "requires": [
  
    ],
    "ensures": [
      "renders static_pages/contact template"
    ]
  }
  ```
- io:
  ```json
  {
    "input": null,
    "output": {
      "status": "200",
      "template": "static_pages/contact"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Public
- perf: Static render
- dependencies:
  ```json
  [
  
  ]
  ```
- example:
  ```json
  {
    "ok": "GET /contact",
    "ng": "POST /contact -> no route"
  }
  ```
- cases:
  ```json
  [
    "TEST-static-contact-route"
  ]
  ```
