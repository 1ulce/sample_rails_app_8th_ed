# app/models/micropost.rb

## Code Annotations

### app/models/micropost.rb#Micropost (line 1)
- id: app/models/micropost.rb#Micropost
- summary: Micropost domain model handling short text updates with optional image attachments
- intent: Persist user-authored posts ordered by recency with validations on content and image uploads
- contract:
  ```json
  {
    "requires": [
      "user reference present",
      "content present and <=140 chars",
      "image complies with content_type/size"
    ],
    "ensures": [
      "records order by created_at desc",
      "image variants available for display"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "attributes": "{user: User, content: String, image: ActiveStorage::Blob?}"
    },
    "output": {
      "record": "Micropost"
    }
  }
  ```
- errors:
  ```json
  [
    "ActiveRecord::RecordInvalid",
    "ActiveRecord::RecordNotFound",
    "ActiveStorage::IntegrityError"
  ]
  ```
- sideEffects: Writes to microposts table and ActiveStorage attachments; creates resize variant on demand
- security: Rejects non-image uploads and large files; inherits user-level authorization from controllers
- perf: Default scope sorts by created_at desc; image variant resize limited to 500x500 to cap processing
- dependencies:
  ```json
  [
    "ActiveRecord",
    "ActiveStorage::Attached::One",
    "Variant resizing",
    "User"
  ]
  ```
- example:
  ```json
  {
    "ok": "users(:michael).microposts.create!(content:\"Hello\", image: fixture_file_upload(\"test/fixtures/files/kitten.png\", \"image/png\"))",
    "ng": "users(:michael).microposts.create!(content:\"\", image:nil) # raises ActiveRecord::RecordInvalid"
  }
  ```
- cases:
  ```json
  [
    "TEST-micropost-validations-basics",
    "TEST-micropost-user-required",
    "TEST-micropost-content-presence",
    "TEST-micropost-content-length",
    "TEST-micropost-default-scope-order"
  ]
  ```
