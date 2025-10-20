# @a:id "app/controllers/password_resets_controller.rb#PasswordResetsController"
# @a:summary "Manage password reset requests, token validation, and credential updates"
# @a:intent "Allow users to request reset emails, validate tokens, and set new passwords securely"
# @a:contract {"requires":["before_actions get_user, valid_user, check_expiration for edit/update"],"ensures":["new renders form","create sends email or re-renders","edit ensures valid token","update enforces password presence and logs user in on success"]}
# @a:io {"input":{"params":"ActionController::Parameters"},"output":{"response":"HTML"}}
# @a:errors ["ActiveRecord::RecordNotFound when email missing in token steps"]
# @a:sideEffects "Sends emails, updates user reset digests, mutates session and flash"
# @a:security "Downcases email, validates activation, checks token expiry, prevents empty passwords"
# @a:perf "Single user lookup per action plus bcrypt updates"
# @a:dependencies ["User","SessionsHelper#log_in","UserMailer","Time.zone"]
# @a:example {"ok":"POST /password_resets with email","ng":"PATCH /password_reset/:id with empty password -> re-render"}
# @a:cases ["TEST-password-reset-new-form","TEST-password-reset-invalid-email","TEST-password-reset-request-updates","TEST-password-reset-form-wrong-email","TEST-password-reset-form-inactive","TEST-password-reset-token-validation","TEST-password-reset-form-valid-token","TEST-password-update-invalid-confirmation","TEST-password-update-empty","TEST-password-update-success","TEST-password-reset-expiry"]
class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]    # Case 1

  # @a:id "app/controllers/password_resets_controller.rb#new"
  # @a:summary "Render password reset request form"
  # @a:intent "Provide UI for submitting email address"
  # @a:contract {"requires":[],"ensures":["renders password_resets/new template"]}
  # @a:io {"input":null,"output":{"status":"200","template":"password_resets/new"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Public route"
  # @a:perf "Static render"
  # @a:dependencies []
  # @a:example {"ok":"GET /password_resets/new","ng":"POST /password_resets/new -> not routed"}
  # @a:cases ["TEST-password-reset-new-form"]
  def new
  end

  # @a:id "app/controllers/password_resets_controller.rb#create"
  # @a:summary "Process reset requests and send reset instructions"
  # @a:intent "Lookup user by email, create reset digest, deliver mail, or re-render on failure"
  # @a:contract {"requires":["params[:password_reset][:email]"],"ensures":["valid email: create_reset_digest, send_password_reset_email, flash info, redirect root","invalid email: flash danger, render new with 422"]}
  # @a:io {"input":{"email":"String"},"output":{"status":"302|422","redirect":"root_url"}}
  # @a:errors []
  # @a:sideEffects "Writes reset digest/timestamp, sends email"
  # @a:security "Downcases email to prevent case bypass"
  # @a:perf "Single user lookup plus digest hashing"
  # @a:dependencies ["User.find_by","User#create_reset_digest","User#send_password_reset_email","flash"]
  # @a:example {"ok":"POST /password_resets email:user@example.com","ng":"POST unknown email -> re-render"}
  # @a:cases ["TEST-password-reset-invalid-email","TEST-password-reset-request-updates"]
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new', status: :unprocessable_entity
    end
  end

  # @a:id "app/controllers/password_resets_controller.rb#edit"
  # @a:summary "Display form to enter new password"
  # @a:intent "Allow users with valid token to set a new password"
  # @a:contract {"requires":["before_actions succeed"],"ensures":["renders password_resets/edit"]}
  # @a:io {"input":{"params":{"email":"String","id":"token"}},"output":{"status":"200","template":"password_resets/edit"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Relies on valid_user and check_expiration"
  # @a:perf "Static render"
  # @a:dependencies []
  # @a:example {"ok":"GET edit_password_reset_path(token,email)","ng":"invalid token -> redirected before render"}
  # @a:cases ["TEST-password-reset-form-valid-token"]
  def edit
  end

  # @a:id "app/controllers/password_resets_controller.rb#update"
  # @a:summary "Apply submitted password changes"
  # @a:intent "Validate new password, update credentials, log user in, or re-render with errors"
  # @a:contract {"requires":["params[:user] with password/password_confirmation"],"ensures":["empty password adds error, renders edit 422","valid update resets session, logs in user, flashes success, redirects profile","other validation failures re-render edit 422"]}
  # @a:io {"input":{"params":{"user":{"password":"String","password_confirmation":"String"}}},"output":{"status":"302|422","redirect":"@user"}}
  # @a:errors []
  # @a:sideEffects "Mutates password digest, resets session id, flashes success"
  # @a:security "Prevents blank password, logs in user securely"
  # @a:perf "Bcrypt hashing cost"
  # @a:dependencies ["user_params","@user.update","reset_session","log_in","flash"]
  # @a:example {"ok":"PATCH password_reset_path(token) with valid password","ng":"PATCH with empty password -> re-render and error"}
  # @a:cases ["TEST-password-update-invalid-confirmation","TEST-password-update-empty","TEST-password-update-success"]
  def update
    if params[:user][:password].empty?                  # Case 3
      @user.errors.add(:password, "can't be empty")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)                     # Case 4
      reset_session
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity      # Case 2
    end
  end

  private

    # @a:id "app/controllers/password_resets_controller.rb#user_params"
    # @a:summary "Strong parameters for password update"
    # @a:intent "Permit only password fields during update"
    # @a:contract {"requires":["params[:user] present"],"ensures":["returns permitted password attributes"]}
    # @a:io {"input":{"params":"ActionController::Parameters"},"output":{"permitted":"ActionController::Parameters"}}
    # @a:errors ["ActionController::ParameterMissing"]
    # @a:sideEffects "none"
    # @a:security "Prevents mass assignment"
    # @a:perf "O(1)"
    # @a:dependencies ["params.require","permit"]
    # @a:example {"ok":"user_params -> {password:\"secret\"}","ng":"params without :user -> raises"}
    # @a:cases ["TEST-password-update-invalid-confirmation","TEST-password-update-empty","TEST-password-update-success"]
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Before filters

    # @a:id "app/controllers/password_resets_controller.rb#get_user"
    # @a:summary "Lookup user by email for token actions"
    # @a:intent "Assign @user used by edit/update filters"
    # @a:contract {"requires":["params[:email]"],"ensures":["@user assigned to matching user or nil"]}
    # @a:io {"input":{"params":{"email":"String"}},"output":{"user":"User|nil"}}
    # @a:errors []
    # @a:sideEffects "Assigns instance variable"
    # @a:security "Delegates verification to valid_user"
    # @a:perf "Single lookup"
    # @a:dependencies ["User.find_by"]
    # @a:example {"ok":"get_user assigns existing user","ng":"get_user when email missing -> @user nil"}
    # @a:cases ["TEST-password-reset-form-wrong-email","TEST-password-reset-form-inactive","TEST-password-reset-form-valid-token","TEST-password-update-success"]
    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
    # @a:id "app/controllers/password_resets_controller.rb#valid_user"
    # @a:summary "Ensure reset link belongs to an activated user with correct token"
    # @a:intent "Block invalid token usage before editing password"
    # @a:contract {"requires":["@user assigned"],"ensures":["redirect root when user missing, inactive, or token mismatch"]}
    # @a:io {"input":{"params":{"id":"token"}},"output":{"redirect_or_continue":"void"}}
    # @a:errors []
    # @a:sideEffects "Redirects to root when invalid"
    # @a:security "Prevents unauthorized reset attempts"
    # @a:perf "O(1)"
    # @a:dependencies ["@user.activated?","@user.authenticated?","redirect_to"]
    # @a:example {"ok":"valid token -> continue","ng":"invalid token -> redirect root"}
    # @a:cases ["TEST-password-reset-form-wrong-email","TEST-password-reset-form-inactive","TEST-password-reset-token-validation","TEST-password-reset-form-valid-token"]
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # Checks expiration of reset token.
    # @a:id "app/controllers/password_resets_controller.rb#check_expiration"
    # @a:summary "Reject reset attempts when token is older than expiry window"
    # @a:intent "Protect against stale reset tokens"
    # @a:contract {"requires":["@user assigned"],"ensures":["redirects to new password reset when expired","allows flow when recent"]}
    # @a:io {"input":null,"output":{"redirect_or_continue":"void"}}
    # @a:errors []
    # @a:sideEffects "Sets flash danger and redirects on expiry"
    # @a:security "Forces user to restart reset flow"
    # @a:perf "O(1)"
    # @a:dependencies ["@user.password_reset_expired?","flash","redirect_to"]
    # @a:example {"ok":"expired -> redirect new_password_reset_url","ng":"fresh -> continue"}
    # @a:cases ["TEST-password-reset-expiry","TEST-password-reset-request-updates"]
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
