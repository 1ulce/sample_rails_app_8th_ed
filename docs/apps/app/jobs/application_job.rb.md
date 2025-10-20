# app/jobs/application_job.rb

## Code Annotations

### app/jobs/application_job.rb#ApplicationJob (line 1)
- id: app/jobs/application_job.rb#ApplicationJob
- summary: Base job class for ActiveJob integrations
- intent: Provide shared configuration hooks for background jobs
- contract:
  ```json
  {
    "requires": [
      "inherit from ActiveJob::Base"
    ],
    "ensures": [
      "retry/discard defaults available"
    ]
  }
  ```
- io:
  ```json
  {
    "input": {
      "job": "Subclass"
    },
    "output": {
      "job_class": "ActiveJob::Base descendant"
    }
  }
  ```
- errors:
  ```json
  [
  
  ]
  ```
- sideEffects: none
- security: Jobs must enforce access control individually
- perf: No additional overhead
- dependencies:
  ```json
  [
    "ActiveJob::Base"
  ]
  ```
- example:
  ```json
  {
    "ok": "class CleanupJob < ApplicationJob; end",
    "ng": "ApplicationJob.perform_now # abstract"
  }
  ```
- cases:
  ```json
  [
  
  ]
  ```
