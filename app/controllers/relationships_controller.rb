# @a:id "app/controllers/relationships_controller.rb#RelationshipsController"
# @a:summary "Handle follow/unfollow actions between users"
# @a:intent "Create and destroy relationship records with HTML and Turbo responses"
# @a:contract {"requires":["logged_in_user before_action"],"ensures":["create follows target user","destroy unfollows target user","HTML responds with redirect, turbo renders stream templates"]}
# @a:io {"input":{"params":"ActionController::Parameters"},"output":{"response":"HTML or Turbo Stream"}}
# @a:errors ["ActiveRecord::RecordNotFound"]
# @a:sideEffects "Mutates relationships table, triggers broadcasts via Turbo templates"
# @a:security "Requires login; ownership enforced by using current_user for follow/unfollow"
# @a:perf "Single read/write operations"
# @a:dependencies ["User","Relationship","current_user.follow","current_user.unfollow"]
# @a:example {"ok":"POST /relationships?followed_id=2","ng":"DELETE /relationships/:id by non-owner before login # redirected"}
# @a:cases ["TEST-relationships-create-login-required","TEST-relationships-destroy-login-required","TEST-users-following-view","TEST-users-followers-view","TEST-user-follow-graph"]
class RelationshipsController < ApplicationController
  before_action :logged_in_user

  # @a:id "app/controllers/relationships_controller.rb#create"
  # @a:summary "Follow another user and respond with redirect or turbo stream"
  # @a:intent "Persist follow relationship initiated from UI"
  # @a:contract {"requires":["params[:followed_id] present"],"ensures":["current_user.follow(target)","HTML redirect to target","Turbo renders default stream"]}
  # @a:io {"input":{"followed_id":"String"},"output":{"status":"302","format":"html|turbo_stream"}}
  # @a:errors ["ActiveRecord::RecordNotFound when user missing"]
  # @a:sideEffects "Inserts Relationship row"
  # @a:security "Uses current_user to prevent spoofing"
  # @a:perf "Single insert"
  # @a:dependencies ["User.find","current_user.follow","respond_to"]
  # @a:example {"ok":"POST /relationships?followed_id=archer.id","ng":"POST without login -> redirected"}
  # @a:cases ["TEST-relationships-create-login-required","TEST-users-following-view","TEST-user-follow-graph"]
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  # @a:id "app/controllers/relationships_controller.rb#destroy"
  # @a:summary "Unfollow a user and respond with redirect or turbo stream"
  # @a:intent "Remove existing relationship from UI actions"
  # @a:contract {"requires":["params[:id] corresponds to relationship current_user follows"],"ensures":["current_user.unfollow(target)","HTML redirect with see_other","Turbo renders default stream"]}
  # @a:io {"input":{"id":"String"},"output":{"status":"303","format":"html|turbo_stream"}}
  # @a:errors ["ActiveRecord::RecordNotFound"]
  # @a:sideEffects "Deletes Relationship row"
  # @a:security "Only relationships involving current_user can be unfollowed"
  # @a:perf "Single delete"
  # @a:dependencies ["Relationship.find","current_user.unfollow","respond_to"]
  # @a:example {"ok":"DELETE /relationships/:id belonging to current_user","ng":"DELETE /relationships/:id while logged out -> redirected"}
  # @a:cases ["TEST-relationships-destroy-login-required","TEST-users-followers-view","TEST-user-follow-graph"]
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
