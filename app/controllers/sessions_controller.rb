# @a:id "app/controllers/sessions_controller.rb#SessionsController"
# @a:summary "Manage user session lifecycle (login/logout)"
# @a:intent "Provide form for credentials, authenticate users, handle remember-me cookies, and end sessions"
# @a:contract {"requires":["SessionsHelper for authentication utilities"],"ensures":["new renders login form","create authenticates and redirects or re-renders","destroy logs out and redirects home"]}
# @a:io {"input":{"params":"ActionController::Parameters"},"output":{"response":"HTML"}}
# @a:errors ["ActiveRecord::RecordNotFound when email missing"]
# @a:sideEffects "Mutates session, cookies, flash messages"
# @a:security "Checks activation status, resets session to prevent fixation, handles remember token securely"
# @a:perf "Database lookup by email plus optional remember updates"
# @a:dependencies ["SessionsHelper","User","remember","forget","log_in","log_out","store_location"]
# @a:example {"ok":"POST /login with valid creds","ng":"POST /login for inactive user -> warns and redirects"}
# @a:cases ["TEST-sessions-new-route","TEST-sessions-new-template","TEST-sessions-invalid-login","TEST-sessions-valid-login","TEST-sessions-valid-login-nav","TEST-users-signup-activation-blocked","TEST-users-signup-activation-success","TEST-sessions-logout-success","TEST-sessions-logout-nav","TEST-sessions-logout-idempotent","TEST-users-login-remember-cookie","TEST-users-login-forget-cookie"]
class SessionsController < ApplicationController

  # @a:id "app/controllers/sessions_controller.rb#new"
  # @a:summary "Render login form"
  # @a:intent "Present fields for email/password"
  # @a:contract {"requires":[],"ensures":["renders sessions/new template"]}
  # @a:io {"input":null,"output":{"status":"200","template":"sessions/new"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "No sensitive data returned"
  # @a:perf "Static render"
  # @a:dependencies []
  # @a:example {"ok":"GET /login","ng":"POST /login -> handled by create"}
  # @a:cases ["TEST-sessions-new-route","TEST-sessions-new-template"]
  def new
  end

  # @a:id "app/controllers/sessions_controller.rb#create"
  # @a:summary "Authenticate credentials and start a session"
  # @a:intent "Handle login submissions with support for remember-me and activation checks"
  # @a:contract {"requires":["params[:session][:email]","params[:session][:password]"],"ensures":["valid user with active account: resets session, optionally remembers, redirects to forwarding_url or profile","inactive user: flashes warning and redirects home","invalid credentials: re-renders new with 422"]}
  # @a:io {"input":{"params":"session email/password, remember_me"},"output":{"status":"302|422","redirect":"user|root","template":"sessions/new on failure"}}
  # @a:errors []
  # @a:sideEffects "Updates session id, cookies, flash, resets stored forwarding url"
  # @a:security "Downcases email, prevents session fixation, handles remember tokens securely, blocks unactivated accounts"
  # @a:perf "Single user lookup and bcrypt authentication"
  # @a:dependencies ["User.find_by","authenticate","remember","forget","log_in","log_out","store_location","session"]
  # @a:example {"ok":"POST /login valid creds -> redirect profile","ng":"POST /login inactive account -> flash warning"}
  # @a:cases ["TEST-sessions-invalid-login","TEST-sessions-valid-login","TEST-sessions-valid-login-nav","TEST-users-signup-activation-blocked","TEST-users-signup-activation-success","TEST-users-login-remember-cookie","TEST-users-login-forget-cookie"]
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user
        redirect_to forwarding_url || user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  # @a:id "app/controllers/sessions_controller.rb#destroy"
  # @a:summary "End the current user session"
  # @a:intent "Log out user safely and redirect home"
  # @a:contract {"requires":[],"ensures":["log_out called if logged in","redirects to root with see_other"]}
  # @a:io {"input":null,"output":{"status":"303","redirect":"root_url"}}
  # @a:errors []
  # @a:sideEffects "Clears remember cookies and session"
  # @a:security "Idempotent logout to prevent replay"
  # @a:perf "O(1)"
  # @a:dependencies ["log_out","logged_in?","reset_session"]
  # @a:example {"ok":"DELETE /logout while logged in","ng":"DELETE /logout while logged out -> still redirects home"}
  # @a:cases ["TEST-sessions-logout-success","TEST-sessions-logout-nav","TEST-sessions-logout-idempotent"]
  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
