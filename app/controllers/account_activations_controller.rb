# @a:id "app/controllers/account_activations_controller.rb#AccountActivationsController"
# @a:summary "Handle email-based account activation via secure tokens"
# @a:intent "Accept activation links, verify tokens, activate accounts, and log users in"
# @a:contract {"requires":["email param","id param as token"],"ensures":["valid unactivated user with matching token gets activated and logged in","invalid token/email redirects with danger flash"]}
# @a:io {"input":{"params":{"email":"String","id":"token"}},"output":{"status":"302","redirect":"user or root"}}
# @a:errors ["ActiveRecord::RecordNotFound when email missing"]
# @a:sideEffects "Updates user activation fields, logs user in, flashes messages"
# @a:security "Validates token via User#authenticated?, ensures user not already activated"
# @a:perf "Single user lookup and update"
# @a:dependencies ["User","User#activate","SessionsHelper#log_in"]
# @a:example {"ok":"GET /account_activations/:token/edit?email=john@example.com","ng":"GET with wrong email -> redirect root"}
# @a:cases ["TEST-users-activation-inactive-default","TEST-users-signup-activation-blocked","TEST-users-activation-invalid-token","TEST-users-activation-invalid-email","TEST-users-signup-activation-success"]
class AccountActivationsController < ApplicationController

  # @a:id "app/controllers/account_activations_controller.rb#edit"
  # @a:summary "Validate activation token and activate user"
  # @a:intent "Complete signup flow after email confirmation"
  # @a:contract {"requires":["params[:email]","params[:id]"],"ensures":["on success: user.activate, log_in user, flash success, redirect to profile","on failure: flash danger and redirect root"]}
  # @a:io {"input":{"params":{"email":"String","id":"token"}},"output":{"status":"302","redirect":"user or root"}}
  # @a:errors []
  # @a:sideEffects "Updates user activation state, logs user in"
  # @a:security "Protects against invalid or already-activated users"
  # @a:perf "O(1)"
  # @a:dependencies ["User.find_by","User#activated?","User#authenticated?","User#activate","log_in"]
  # @a:example {"ok":"GET edit_account_activation_path(valid_token,email:user.email)","ng":"GET with invalid token -> redirect root"}
  # @a:cases ["TEST-users-signup-activation-blocked","TEST-users-activation-invalid-token","TEST-users-activation-invalid-email","TEST-users-signup-activation-success"]
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
