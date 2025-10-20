# @a:id "app/controllers/users_controller.rb#UsersController"
# @a:summary "Endpoints for user CRUD, follow lists, and access control"
# @a:intent "Expose HTML flows for listing, showing, editing, and destroying users with proper auth guards"
# @a:contract {"requires":["logged_in_user before_action for protected routes"],"ensures":["non-admins cannot destroy users","users can only edit/update themselves"]}
# @a:io {"input":{"params":"ActionController::Parameters"},"output":{"response":"HTML"}}
# @a:errors ["ActiveRecord::RecordNotFound","ActionController::ParameterMissing"]
# @a:sideEffects "Reads/writes users table, flashes session data, triggers mailer on create"
# @a:security "Enforces login, ownership, and admin checks; relies on `current_user?` and `current_user` helpers"
# @a:perf "Pagination queries O(n) per page; follow lists load via association scopes"
# @a:dependencies ["User","Micropost","will_paginate","current_user?","logged_in_user"]
# @a:example {"ok":"GET /users?page=2","ng":"DELETE /users/:id by non-admin # redirected"}
# @a:cases ["TEST-users-index-auth","TEST-users-index-admin-list","TEST-users-index-non-admin-no-delete","TEST-users-profile-feed","TEST-users-edit-authorization","TEST-users-destroy-admin-only","TEST-users-following-list","TEST-users-following-view","TEST-users-followers-list","TEST-users-followers-view"]
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  # @a:id "app/controllers/users_controller.rb#index"
  # @a:summary "List activated users with pagination"
  # @a:intent "Provide admin/regular access to user directory"
  # @a:contract {"requires":["logged_in_user before_action"],"ensures":["assigns @users paginate result"]}
  # @a:io {"input":{"page":"params[:page] String"},"output":{"status":"200","template":"users/index"}}
  # @a:errors []
  # @a:sideEffects "Reads paginated users"
  # @a:security "Requires authenticated session"
  # @a:perf "Pagination query O(n) per page"
  # @a:dependencies ["User.paginate"]
  # @a:example {"ok":"GET /users?page=1","ng":"Unauthenticated GET /users # redirected"}
  # @a:cases ["TEST-users-index-auth","TEST-users-index-admin-list","TEST-users-index-non-admin-no-delete"]
  def index
    @users = User.paginate(page: params[:page])
  end

  # @a:id "app/controllers/users_controller.rb#show"
  # @a:summary "Render user profile and paginated microposts"
  # @a:intent "Display profile page with timeline"
  # @a:contract {"requires":["id param resolves to user"],"ensures":["assigns @user and @microposts"]}
  # @a:io {"input":{"id":"params[:id]"},"output":{"status":"200","template":"users/show"}}
  # @a:errors ["ActiveRecord::RecordNotFound when id invalid"]
  # @a:sideEffects "Reads microposts with pagination"
  # @a:security "Accessible publicly for activated users"
  # @a:perf "Paginated query plus includes"
  # @a:dependencies ["User.find","Micropost.paginate"]
  # @a:example {"ok":"GET /users/1","ng":"GET /users/9999 # raises ActiveRecord::RecordNotFound"}
  # @a:cases ["TEST-users-profile-feed"]
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  # @a:id "app/controllers/users_controller.rb#new"
  # @a:summary "Instantiate unsaved user for signup form"
  # @a:intent "Render signup page"
  # @a:contract {"requires":[],"ensures":["assigns @user = User.new"]}
  # @a:io {"input":null,"output":{"status":"200","template":"users/new"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Public route"
  # @a:perf "O(1)"
  # @a:dependencies ["User.new"]
  # @a:example {"ok":"GET /signup","ng":"(n/a)"}
  # @a:cases ["TEST-users-signup-invalid"]
  def new
    @user = User.new
  end

  # @a:id "app/controllers/users_controller.rb#create"
  # @a:summary "Persist new user and trigger activation email"
  # @a:intent "Handle signup submissions with optimistic activation flow"
  # @a:contract {"requires":["user_params with name,email,password,password_confirmation"],"ensures":["on success: user saved, activation email sent, redirect root","on failure: re-render new with 422"]}
  # @a:io {"input":{"params":"user_params"},"output":{"status":"302|422","template":"redirect or users/new"}}
  # @a:errors ["ActionController::ParameterMissing when :user absent"]
  # @a:sideEffects "Writes user, sends email, flashes info"
  # @a:security "Relies on strong params; account remains inactive until activation"
  # @a:perf "Single insert + email send"
  # @a:dependencies ["UserMailer.account_activation","User#send_activation_email"]
  # @a:example {"ok":"POST /users valid payload","ng":"POST /users missing email #=> 422"}
  # @a:cases ["TEST-users-signup-invalid","TEST-users-signup-activation-flow"]
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # @a:id "app/controllers/users_controller.rb#edit"
  # @a:summary "Render edit profile form for current user"
  # @a:intent "Allow users to update attributes"
  # @a:contract {"requires":["correct_user before_action"],"ensures":["assigns @user"]} 
  # @a:io {"input":{"id":"params[:id]"},"output":{"status":"200","template":"users/edit"}}
  # @a:errors ["ActiveRecord::RecordNotFound when id invalid"]
  # @a:sideEffects "Reads user record"
  # @a:security "Requires login and ownership check"
  # @a:perf "O(1)"
  # @a:dependencies ["User.find","correct_user"]
  # @a:example {"ok":"GET /users/1/edit when logged in as same user","ng":"GET /users/1/edit by other user # redirected"}
  # @a:cases ["TEST-users-edit-login-required","TEST-users-edit-authorization","TEST-users-edit-wrong-user"]
  def edit
    @user = User.find(params[:id])
  end

  # @a:id "app/controllers/users_controller.rb#update"
  # @a:summary "Persist profile changes for the current user"
  # @a:intent "Apply permitted attribute updates with optimistic redirect"
  # @a:contract {"requires":["correct_user before_action","user_params present"],"ensures":["on success: flash success, redirect to @user","on failure: render edit 422"]}
  # @a:io {"input":{"params":"user_params"},"output":{"status":"302|422","template":"redirect or users/edit"}}
  # @a:errors ["ActiveRecord::RecordNotFound","ActionController::ParameterMissing"]
  # @a:sideEffects "Writes users table; sets flash"
  # @a:security "Only same user may update; admin privileges not required"
  # @a:perf "Single update"
  # @a:dependencies ["User.find","correct_user"]
  # @a:example {"ok":"PATCH /users/:id with valid data","ng":"PATCH /users/:id by other user # redirected"}
  # @a:cases ["TEST-users-update-login-required","TEST-users-edit-authorization","TEST-users-update-validations","TEST-users-update-wrong-user"]
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  # @a:id "app/controllers/users_controller.rb#destroy"
  # @a:summary "Delete user as admin-only action"
  # @a:intent "Allow administrators to remove accounts"
  # @a:contract {"requires":["admin_user before_action"],"ensures":["user destroyed","redirect to users_url with see_other"]}
  # @a:io {"input":{"id":"params[:id]"},"output":{"status":"303","redirect":"users_url"}}
  # @a:errors ["ActiveRecord::RecordNotFound"]
  # @a:sideEffects "Deletes user, cascades microposts/relationships"
  # @a:security "Requires admin current_user"
  # @a:perf "Single delete with dependent cleanup"
  # @a:dependencies ["User.find","admin_user"]
  # @a:example {"ok":"DELETE /users/:id by admin","ng":"DELETE /users/:id by regular user # redirected"}
  # @a:cases ["TEST-users-destroy-login-required","TEST-users-destroy-admin-only"]
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  # @a:id "app/controllers/users_controller.rb#following"
  # @a:summary "Show paginated list of users the target user follows"
  # @a:intent "Render follow relationships for UI"
  # @a:contract {"requires":["logged_in_user before_action"],"ensures":["assigns @user,@users,@title","renders show_follow"]}
  # @a:io {"input":{"id":"params[:id]"},"output":{"status":"422","template":"users/show_follow"}}
  # @a:errors ["ActiveRecord::RecordNotFound"]
  # @a:sideEffects "Reads following association"
  # @a:security "Requires login but not ownership"
  # @a:perf "Paginated query on relationships join"
  # @a:dependencies ["User.following","paginate"]
  # @a:example {"ok":"GET /users/:id/following","ng":"GET /users/:id/following while logged out # redirected"}
  # @a:cases ["TEST-users-following-list","TEST-users-following-view"]
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow', status: :unprocessable_entity
  end

  # @a:id "app/controllers/users_controller.rb#followers"
  # @a:summary "Show paginated list of users that follow the target user"
  # @a:intent "Render followers panel"
  # @a:contract {"requires":["logged_in_user before_action"],"ensures":["assigns @user,@users,@title","renders show_follow"]}
  # @a:io {"input":{"id":"params[:id]"},"output":{"status":"422","template":"users/show_follow"}}
  # @a:errors ["ActiveRecord::RecordNotFound"]
  # @a:sideEffects "Reads followers association"
  # @a:security "Requires login"
  # @a:perf "Paginated query on relationships join"
  # @a:dependencies ["User.followers","paginate"]
  # @a:example {"ok":"GET /users/:id/followers","ng":"GET /users/:id/followers while logged out # redirected"}
  # @a:cases ["TEST-users-followers-list","TEST-users-followers-view"]
  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow', status: :unprocessable_entity
  end

  private

    # @a:id "app/controllers/users_controller.rb#user_params"
    # @a:summary "Strong parameter whitelist for user attributes"
    # @a:intent "Prevent mass-assignment of unsafe fields"
    # @a:contract {"requires":["params[:user] present"],"ensures":["returns permitted params for name,email,password,password_confirmation"]}
    # @a:io {"input":{"params":"ActionController::Parameters"},"output":{"permitted":"ActionController::Parameters"}}
    # @a:errors ["ActionController::ParameterMissing when :user absent"]
    # @a:sideEffects "none"
    # @a:security "Blocks role escalation; whitelist only safe fields"
    # @a:perf "O(1)"
    # @a:dependencies ["params.require","permit"]
    # @a:example {"ok":"user_params #=> {name:..., email:...}","ng":"params without :user # raises ActionController::ParameterMissing"}
    # @a:cases ["TEST-users-signup-invalid","TEST-users-update-validations"]
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # Before filters

    # @a:id "app/controllers/users_controller.rb#correct_user"
    # @a:summary "Redirect unless the requested user matches current_user"
    # @a:intent "Enforce ownership for edit/update"
    # @a:contract {"requires":["logged_in_user already ran"],"ensures":["redirects to root with 303 when user mismatch","assigns @user on success"]}
    # @a:io {"input":{"id":"params[:id]"},"output":{"redirect_or_continue":"void"}}
    # @a:errors ["ActiveRecord::RecordNotFound"]
    # @a:sideEffects "Sets @user; may redirect via controller helper"
    # @a:security "Prevents users from editing others' profiles"
    # @a:perf "O(1)"
    # @a:dependencies ["User.find","current_user?","root_url"]
    # @a:example {"ok":"correct_user when ids match","ng":"correct_user when mismatch # redirects root"}
    # @a:cases ["TEST-users-edit-authorization","TEST-users-edit-wrong-user","TEST-users-update-wrong-user"]
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # @a:id "app/controllers/users_controller.rb#admin_user"
    # @a:summary "Redirect unless current user has admin flag"
    # @a:intent "Gate destructive actions to administrators"
    # @a:contract {"requires":["logged_in_user already ran"],"ensures":["redirects to root when current_user.admin? is false"]}
    # @a:io {"input":null,"output":{"redirect_or_continue":"void"}}
    # @a:errors []
    # @a:sideEffects "none"
    # @a:security "Blocks non-admin destroy attempts"
    # @a:perf "O(1)"
    # @a:dependencies ["current_user","root_url"]
    # @a:example {"ok":"admin_user when admin true","ng":"admin_user when false # redirects root"}
    # @a:cases ["TEST-users-destroy-login-required","TEST-users-destroy-admin-only"]
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
