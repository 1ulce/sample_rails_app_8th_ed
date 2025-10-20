# @a:id "app/helpers/users_helper.rb#UsersHelper"
# @a:summary "View helpers for user presentation"
# @a:intent "Provide pure helpers shared across views"
# @a:contract {"requires":[],"ensures":["helpers return HTML-safe strings"]}
# @a:io {"input":{"view_context":"ActionView::Base"},"output":{"helpers":"String or ActiveSupport::SafeBuffer"}}
# @a:errors []
# @a:sideEffects "none"
# @a:security "Ensure generated markup does not leak secrets"
# @a:perf "O(1)"
# @a:dependencies ["Digest::MD5","image_tag"]
# @a:example {"ok":"gravatar_for(users(:michael))","ng":"gravatar_for(nil) # raises NoMethodError"}
# @a:cases ["TEST-users-gravatar-helper"]
module UsersHelper

  # @a:id "app/helpers/users_helper.rb#gravatar_for"
  # @a:summary "Build gravatar image tag for given user email"
  # @a:intent "Render avatar thumbnails with configurable size"
  # @a:contract {"requires":["user responds to email and name"],"ensures":["returns image_tag HTML"]}
  # @a:io {"input":{"user":"User","options":"{size: Integer}"},"output":{"markup":"ActiveSupport::SafeBuffer"}}
  # @a:errors ["NoMethodError when user lacks email"]
  # @a:sideEffects "none"
  # @a:security "Uses HTTPS gravatar endpoint; does not expose raw email"
  # @a:perf "MD5 hash computation O(length email)"
  # @a:dependencies ["Digest::MD5","image_tag"]
  # @a:example {"ok":"gravatar_for(user, size: 40)","ng":"gravatar_for(user, size: -1) # broken gravatar URL"}
  # @a:cases ["TEST-users-gravatar-helper"]
  def gravatar_for(user, options = { size: 80 })
    size         = options[:size]
    gravatar_id  = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
