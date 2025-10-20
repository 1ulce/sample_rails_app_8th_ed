# @a:id "app/jobs/application_job.rb#ApplicationJob"
# @a:summary "Base job class for ActiveJob integrations"
# @a:intent "Provide shared configuration hooks for background jobs"
# @a:contract {"requires":["inherit from ActiveJob::Base"],"ensures":["retry/discard defaults available"]}
# @a:io {"input":{"job":"Subclass"},"output":{"job_class":"ActiveJob::Base descendant"}}
# @a:errors []
# @a:sideEffects "none"
# @a:security "Jobs must enforce access control individually"
# @a:perf "No additional overhead"
# @a:dependencies ["ActiveJob::Base"]
# @a:example {"ok":"class CleanupJob < ApplicationJob; end","ng":"ApplicationJob.perform_now # abstract"}
# @a:cases []
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
