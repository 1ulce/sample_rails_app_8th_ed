# @a:id "app/controllers/application_controller.rb#ApplicationController"
# @a:summary "Global controller base with session helpers and authentication guard"
# @a:intent "Provide cross-cutting helpers and filters for downstream controllers"
# @a:contract {"requires":["include SessionsHelper"],"ensures":["logged_in_user filter available to enforce access control"]}
# @a:io {"input":{"request":"ActionDispatch::Request"},"output":{"response":"ActionDispatch::Response"}}
# @a:errors []
# @a:sideEffects "Manages flash state and redirects during authentication checks"
# @a:security "Centralizes login enforcement via SessionsHelper"
# @a:perf "Minimal"
# @a:dependencies ["SessionsHelper","flash","redirect_to"]
# @a:example {"ok":"before_action :logged_in_user","ng":"calling logged_in_user without SessionsHelper including logged_in? # raises NoMethodError"}
# @a:cases ["TEST-users-index-auth","TEST-users-edit-login-required","TEST-users-update-login-required","TEST-users-destroy-login-required","TEST-microposts-create-auth","TEST-microposts-destroy-auth","TEST-relationships-create-login-required","TEST-relationships-destroy-login-required","TEST-users-following-list","TEST-users-followers-list"]
class ApplicationController < ActionController::Base
  include SessionsHelper

  private

    # @a:id "app/controllers/application_controller.rb#logged_in_user"
    # @a:summary "Redirect unauthenticated requests to the login page"
    # @a:intent "Ensure protected routes can only be accessed by signed-in users"
    # @a:contract {"requires":[],"ensures":["when logged_in? false: sets flash, stores requested URL, redirects login_url with 303","when logged_in? true: no redirect"]}
    # @a:io {"input":null,"output":{"redirect_or_continue":"void"}}
    # @a:errors []
    # @a:sideEffects "Stores forwarding URL, mutates flash, triggers redirect"
    # @a:security "Prevents unauthorized access to member-only pages"
    # @a:perf "O(1)"
    # @a:dependencies ["logged_in?","store_location","flash","redirect_to","login_url"]
    # @a:example {"ok":"logged_in_user when logged out -> redirect to login","ng":"logged_in_user when logged in -> no redirect"}
    # @a:cases ["TEST-users-index-auth","TEST-users-edit-login-required","TEST-users-update-login-required","TEST-users-destroy-login-required","TEST-microposts-create-auth","TEST-microposts-destroy-auth","TEST-relationships-create-login-required","TEST-relationships-destroy-login-required","TEST-users-following-list","TEST-users-followers-list"]
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end
end
