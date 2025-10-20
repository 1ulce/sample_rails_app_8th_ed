# @a:id "app/controllers/microposts_controller.rb#MicropostsController"
# @a:summary "Manage creation and deletion of microposts for authenticated users"
# @a:intent "Expose minimal REST endpoints to post status updates and remove owned posts while enforcing access control"
# @a:contract {"requires":["logged_in_user before_action"],"ensures":["create builds micropost for current_user","destroy only removes posts owned by current user"]}
# @a:io {"input":{"params":"ActionController::Parameters"},"output":{"response":"HTML"}}
# @a:errors ["ActiveRecord::RecordInvalid","ActiveRecord::RecordNotFound","ActionController::ParameterMissing"]
# @a:sideEffects "Writes to microposts table, attaches ActiveStorage blobs, flashes messages"
# @a:security "Authenticated-only actions; ownership enforced in correct_user"
# @a:perf "Create includes optional image attach; feed reload limited via pagination"
# @a:dependencies ["Micropost","logged_in_user","correct_user","current_user.feed","ActiveStorage::Attached"]
# @a:example {"ok":"POST /microposts {content:\"Hello\"}","ng":"DELETE /microposts/:id by other user # redirected"}
# @a:cases ["TEST-microposts-create-auth","TEST-microposts-destroy-auth","TEST-microposts-destroy-ownership","TEST-microposts-interface-crud"]
class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  # @a:id "app/controllers/microposts_controller.rb#create"
  # @a:summary "Persist a new micropost for the signed-in user and refresh home feed"
  # @a:intent "Handle form submissions with optional image upload"
  # @a:contract {"requires":["current_user present","micropost_params includes content and optional image"],"ensures":["on success: micropost saved, redirect root","on failure: render static_pages/home with feed items"]}
  # @a:io {"input":{"params":"micropost_params"},"output":{"status":"302|422","template":"redirect or static_pages/home"}}
  # @a:errors ["ActionController::ParameterMissing","ActiveRecord::RecordInvalid","ActiveStorage::IntegrityError"]
  # @a:sideEffects "Creates Micropost record, attaches uploaded image, flashes success on success, populates @feed_items on failure"
  # @a:security "Requires logged in user; content sanitized via Rails helpers"
  # @a:perf "Single insert plus potential ActiveStorage attach"
  # @a:dependencies ["current_user.microposts.build","current_user.feed.paginate","Micropost"]
  # @a:example {"ok":"POST /microposts content:\"Hi\" -> redirect root","ng":"POST /microposts while logged out -> redirected login"}
  # @a:cases ["TEST-microposts-create-auth","TEST-microposts-interface-crud"]
  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  # @a:id "app/controllers/microposts_controller.rb#destroy"
  # @a:summary "Delete an owned micropost and redirect back to the referring page"
  # @a:intent "Allow users to remove their posts while respecting referer fallback"
  # @a:contract {"requires":["correct_user before_action found micropost"],"ensures":["micropost destroyed","redirect to referrer or root with 303"]}
  # @a:io {"input":{"id":"params[:id]"},"output":{"status":"303","redirect":"referrer or root"}}
  # @a:errors ["ActiveRecord::RecordNotFound"]
  # @a:sideEffects "Deletes Micropost record and associated attachments; flashes success"
  # @a:security "Ownership enforced via correct_user"
  # @a:perf "Single delete and optional ActiveStorage cleanup"
  # @a:dependencies ["correct_user","request.referrer","Micropost"]
  # @a:example {"ok":"DELETE /microposts/:id for own post -> redirect back","ng":"DELETE /microposts/:id by other user -> redirected root"}
  # @a:cases ["TEST-microposts-destroy-auth","TEST-microposts-destroy-ownership","TEST-microposts-interface-crud"]
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    if request.referrer.nil?
      redirect_to root_url, status: :see_other
    else
      redirect_to request.referrer, status: :see_other
    end
  end

  private

    # @a:id "app/controllers/microposts_controller.rb#micropost_params"
    # @a:summary "Permit micropost content and image parameters"
    # @a:intent "Protect against mass assignment"
    # @a:contract {"requires":["params[:micropost] present"],"ensures":["returns permitted content and image keys only"]}
    # @a:io {"input":{"params":"ActionController::Parameters"},"output":{"permitted":"ActionController::Parameters"}}
    # @a:errors ["ActionController::ParameterMissing"]
    # @a:sideEffects "none"
    # @a:security "Prevents malicious attribute injection"
    # @a:perf "O(1)"
    # @a:dependencies ["params.require","permit"]
    # @a:example {"ok":"micropost_params #=> {content: \"Hi\"}","ng":"params without :micropost -> raises ActionController::ParameterMissing"}
    # @a:cases ["TEST-microposts-interface-crud"]
    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    # @a:id "app/controllers/microposts_controller.rb#correct_user"
    # @a:summary "Locate micropost belonging to current user or redirect"
    # @a:intent "Enforce ownership before destructive actions"
    # @a:contract {"requires":["current_user present"],"ensures":["assigns @micropost when owned","redirects to root with 303 when not found"]}
    # @a:io {"input":{"id":"params[:id]"},"output":{"redirect_or_continue":"void"}}
    # @a:errors []
    # @a:sideEffects "Sets @micropost or redirects"
    # @a:security "Prevents deleting posts from other users"
    # @a:perf "Single lookup scoped to current_user"
    # @a:dependencies ["current_user.microposts.find_by","root_url"]
    # @a:example {"ok":"correct_user finds own micropost","ng":"correct_user on others' micropost -> redirect root"}
    # @a:cases ["TEST-microposts-destroy-ownership","TEST-microposts-interface-crud"]
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to(root_url, status: :see_other) if @micropost.nil?
    end
end
