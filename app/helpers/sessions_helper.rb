# @a:id "app/helpers/sessions_helper.rb#SessionsHelper"
# @a:summary "Session management helpers for authentication state"
# @a:intent "Encapsulate session, cookie, and current user logic for controllers and views"
# @a:contract {"requires":[],"ensures":["log_in stores user id and token","remember persists cookie-based session","current_user memoizes user","log_out clears session and cookies","store_location saves GET URLs"]}
# @a:io {"input":{"request":"ActionDispatch::Request"},"output":{"session_state":"Mutated session/cookies"}}
# @a:errors []
# @a:sideEffects "Mutates session and cookies; memoizes @current_user"
# @a:security "Mitigates session fixation by storing session_token; encrypts cookies"
# @a:perf "O(1) operations"
# @a:dependencies ["User","session","cookies","reset_session"]
# @a:example {"ok":"log_in(user) followed by current_user -> user","ng":"remember(nil) # raises NoMethodError"}
# @a:cases ["TEST-sessions-valid-login","TEST-sessions-valid-login-nav","TEST-sessions-invalid-login","TEST-sessions-logout-success","TEST-sessions-logout-idempotent","TEST-users-login-remember-cookie","TEST-users-login-forget-cookie","TEST-password-update-success","TEST-users-edit-authorization","TEST-users-update-validations","TEST-users-following-view","TEST-sessions-helper-current-user","TEST-sessions-helper-invalid-remember"]
module SessionsHelper

  # @a:id "app/helpers/sessions_helper.rb#log_in"
  # @a:summary "Persist session data for the authenticated user"
  # @a:intent "Record user id and session token in Rails session storage"
  # @a:contract {"requires":["user responds to id and session_token"],"ensures":["session[:user_id] and session[:session_token] set"]}
  # @a:io {"input":{"user":"User"},"output":{"session":"mutated"}}
  # @a:errors []
  # @a:sideEffects "Mutates session hash"
  # @a:security "Stores session_token to detect hijacking"
  # @a:perf "O(1)"
  # @a:dependencies ["session"]
  # @a:example {"ok":"log_in(user)","ng":"log_in(nil) # raises NoMethodError"}
  # @a:cases ["TEST-sessions-valid-login","TEST-sessions-valid-login-nav","TEST-password-update-success","TEST-users-signup-activation-success"]
  def log_in(user)
    session[:user_id] = user.id
    # Guard against session replay attacks.
    # See https://bit.ly/33UvK0w for more.
    session[:session_token] = user.session_token
  end

  # @a:id "app/helpers/sessions_helper.rb#remember"
  # @a:summary "Set permanent cookies to keep a user logged in across sessions"
  # @a:intent "Call User#remember and store encrypted identifiers in cookies"
  # @a:contract {"requires":["user responds to remember, remember_token, id"],"ensures":["permanent encrypted user_id cookie set","permanent remember_token cookie set"]}
  # @a:io {"input":{"user":"User"},"output":{"cookies":"mutated"}}
  # @a:errors []
  # @a:sideEffects "Writes persistent cookies"
  # @a:security "Stores user_id encrypted, raw token stored separately for verification"
  # @a:perf "O(1)"
  # @a:dependencies ["user.remember","cookies.permanent"]
  # @a:example {"ok":"remember(user)","ng":"remember(nil) # raises NoMethodError"}
  # @a:cases ["TEST-users-login-remember-cookie","TEST-sessions-valid-login"]
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # @a:id "app/helpers/sessions_helper.rb#current_user"
  # @a:summary "Retrieve and memoize the currently logged-in user"
  # @a:intent "Check session, verify token, and lazy-load user object"
  # @a:contract {"requires":[],"ensures":["returns User or nil","memoizes @current_user when found","verifies session token or remember cookie before setting"]}
  # @a:io {"input":null,"output":{"user":"User|nil"}}
  # @a:errors []
  # @a:sideEffects "May call log_in when authenticating via remember cookie"
  # @a:security "Compares session token to stored digest to prevent replay"
  # @a:perf "Two lookups at most (session branch or cookie branch)"
  # @a:dependencies ["session","cookies","User.find_by","user.authenticated?","remember"]
  # @a:example {"ok":"current_user #=> logged in user","ng":"current_user without session/cookie #=> nil"}
  # @a:cases ["TEST-sessions-valid-login","TEST-sessions-valid-login-nav","TEST-sessions-logout-success","TEST-users-login-remember-cookie","TEST-users-login-forget-cookie","TEST-sessions-new-template","TEST-sessions-invalid-login","TEST-password-update-success"]
  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # @a:id "app/helpers/sessions_helper.rb#current_user?"
  # @a:summary "Check whether a given user matches the logged-in user"
  # @a:intent "Provide convenient equality check for authorization"
  # @a:contract {"requires":["user may be nil"],"ensures":["returns true when provided user equals current_user"]}
  # @a:io {"input":{"user":"User|nil"},"output":{"matches":"Boolean"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Used by controllers to gate editing"
  # @a:perf "O(1)"
  # @a:dependencies ["current_user"]
  # @a:example {"ok":"current_user?(current_user) #=> true","ng":"current_user?(nil) #=> false"}
  # @a:cases ["TEST-users-edit-authorization","TEST-users-update-wrong-user","TEST-users-following-view"]
  def current_user?(user)
    user && user == current_user
  end

  # @a:id "app/helpers/sessions_helper.rb#logged_in?"
  # @a:summary "Boolean helper indicating session presence"
  # @a:intent "Allow views/controllers to gate content based on login state"
  # @a:contract {"requires":[],"ensures":["returns true iff current_user present"]}
  # @a:io {"input":null,"output":{"logged_in":"Boolean"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Used in before_action guards"
  # @a:perf "Depends on current_user memoization"
  # @a:dependencies ["current_user"]
  # @a:example {"ok":"log_in(user); logged_in? #=> true","ng":"reset_session; logged_in? #=> false"}
  # @a:cases ["TEST-users-index-auth","TEST-users-edit-login-required","TEST-microposts-create-auth","TEST-relationships-create-login-required","TEST-sessions-logout-idempotent"]
  def logged_in?
    !current_user.nil?
  end

  # @a:id "app/helpers/sessions_helper.rb#forget"
  # @a:summary "Clear remember-me cookies for a user"
  # @a:intent "Invalidate persistent login tokens"
  # @a:contract {"requires":["user responds to forget"],"ensures":["remember cookies removed"]}
  # @a:io {"input":{"user":"User"},"output":{"cookies":"mutated"}}
  # @a:errors []
  # @a:sideEffects "Deletes cookies and resets user's remember digest"
  # @a:security "Prevents stolen cookie reuse"
  # @a:perf "O(1)"
  # @a:dependencies ["user.forget","cookies.delete"]
  # @a:example {"ok":"forget(current_user)","ng":"forget(nil) # raises"}
  # @a:cases ["TEST-users-login-forget-cookie","TEST-sessions-logout-success"]
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # @a:id "app/helpers/sessions_helper.rb#log_out"
  # @a:summary "Terminate session and forget persistent login"
  # @a:intent "Log out user safely, clearing all session state"
  # @a:contract {"requires":[],"ensures":["forget called with current_user","session reset","@current_user nil"]}
  # @a:io {"input":null,"output":{"session":"reset","cookies":"cleared"}}
  # @a:errors []
  # @a:sideEffects "Mutates session and cookies"
  # @a:security "Resets session id to prevent fixation"
  # @a:perf "O(1)"
  # @a:dependencies ["forget","reset_session"]
  # @a:example {"ok":"log_out","ng":"log_out when current_user is nil -> no-op"}
  # @a:cases ["TEST-sessions-logout-success","TEST-sessions-logout-idempotent","TEST-sessions-logout-nav"]
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end

  # @a:id "app/helpers/sessions_helper.rb#store_location"
  # @a:summary "Save intended URL to redirect after login"
  # @a:intent "Enable friendly forwarding for GET requests"
  # @a:contract {"requires":["request available"],"ensures":["stores request.original_url in session[:forwarding_url] when GET"]}
  # @a:io {"input":null,"output":{"session":"mutated"}}
  # @a:errors []
  # @a:sideEffects "Writes session[:forwarding_url]"
  # @a:security "Ignores non-GET requests to avoid CSRF vectors"
  # @a:perf "O(1)"
  # @a:dependencies ["session","request"]
  # @a:example {"ok":"store_location when GET /users/1/edit","ng":"store_location on POST -> no change"}
  # @a:cases ["TEST-users-edit-login-required","TEST-users-update-login-required","TEST-users-edit-authorization"]
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
