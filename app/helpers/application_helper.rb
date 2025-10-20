# @a:id "app/helpers/application_helper.rb#ApplicationHelper"
# @a:summary "Global view helpers shared across layouts"
# @a:intent "Provide convenience methods like dynamic page titles"
# @a:contract {"requires":[],"ensures":["helpers return HTML-safe strings or primitives"]}
# @a:io {"input":{"view_context":"ActionView::Base"},"output":{"helpers":"String"}}
# @a:errors []
# @a:sideEffects "none"
# @a:security "No sensitive data exposure"
# @a:perf "O(1)"
# @a:dependencies []
# @a:example {"ok":"full_title(\"Help\") #=> \"Help | Ruby on Rails Tutorial Sample App\"","ng":"full_title(nil) # raises NoMethodError"}
# @a:cases ["TEST-application-full-title"]
module ApplicationHelper

  # @a:id "app/helpers/application_helper.rb#full_title"
  # @a:summary "Compose full HTML title from base title and optional page segment"
  # @a:intent "Avoid duplicate code for setting document titles"
  # @a:contract {"requires":["page_title optional string"],"ensures":["returns base title when blank","returns \"{page} | {base}\" otherwise"]}
  # @a:io {"input":{"page_title":"String"},"output":{"title":"String"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "No sensitive data"
  # @a:perf "O(1)"
  # @a:dependencies []
  # @a:example {"ok":"full_title(\"Help\") #=> \"Help | Ruby on Rails Tutorial Sample App\"","ng":"full_title(nil) # raises NoMethodError"}
  # @a:cases ["TEST-application-full-title","TEST-users-profile-feed","TEST-static-help-route"]
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
end
