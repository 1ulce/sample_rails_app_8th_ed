# @a:id "app/controllers/static_pages_controller.rb#StaticPagesController"
# @a:summary "Render static marketing pages and the home feed"
# @a:intent "Serve publicly accessible pages plus authenticated home timeline"
# @a:contract {"requires":[],"ensures":["home assigns feed data when logged in","help/about/contact render respective templates"]}
# @a:io {"input":{"request":"ActionDispatch::Request"},"output":{"response":"HTML"}}
# @a:errors []
# @a:sideEffects "Reads current_user feed for home page"
# @a:security "Home leverages SessionsHelper to conditionally render feed"
# @a:perf "Feed pagination query executed only when logged in"
# @a:dependencies ["current_user","Micropost","paginate"]
# @a:example {"ok":"GET / -> home with feed for logged-in user","ng":"PATCH /help -> no route"}
# @a:cases ["TEST-static-home-route","TEST-static-help-route","TEST-static-about-route","TEST-static-contact-route","TEST-microposts-interface-crud","TEST-users-profile-feed"]
class StaticPagesController < ApplicationController

  # @a:id "app/controllers/static_pages_controller.rb#home"
  # @a:summary "Render home page and bootstrap feed for logged-in users"
  # @a:intent "Show signup CTA to guests and micropost feed to members"
  # @a:contract {"requires":[],"ensures":["assigns @micropost and @feed_items when logged_in?","does not assign feed objects for guests"]}
  # @a:io {"input":{"params":{"page":"String?"}},"output":{"status":"200","template":"static_pages/home"}}
  # @a:errors []
  # @a:sideEffects "Reads current_user feed; instantiates unsaved micropost"
  # @a:security "Depends on logged_in? to expose user-specific data"
  # @a:perf "Feed pagination query with includes (same as User#feed)"
  # @a:dependencies ["logged_in?","current_user.microposts.build","current_user.feed.paginate"]
  # @a:example {"ok":"GET home when logged in -> feed populated","ng":"GET home when logged out -> no @feed_items"}
  # @a:cases ["TEST-static-home-route","TEST-microposts-interface-crud"]
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  # @a:id "app/controllers/static_pages_controller.rb#help"
  # @a:summary "Render help page"
  # @a:intent "Provide documentation/FAQ content"
  # @a:contract {"requires":[],"ensures":["renders static_pages/help template"]}
  # @a:io {"input":null,"output":{"status":"200","template":"static_pages/help"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Public"
  # @a:perf "Static render"
  # @a:dependencies []
  # @a:example {"ok":"GET /help","ng":"POST /help -> not routed"}
  # @a:cases ["TEST-static-help-route"]
  def help
  end

  # @a:id "app/controllers/static_pages_controller.rb#about"
  # @a:summary "Render about page"
  # @a:intent "Share project background"
  # @a:contract {"requires":[],"ensures":["renders static_pages/about template"]}
  # @a:io {"input":null,"output":{"status":"200","template":"static_pages/about"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Public"
  # @a:perf "Static render"
  # @a:dependencies []
  # @a:example {"ok":"GET /about","ng":"POST /about -> no route"}
  # @a:cases ["TEST-static-about-route"]
  def about
  end

  # @a:id "app/controllers/static_pages_controller.rb#contact"
  # @a:summary "Render contact page"
  # @a:intent "Expose contact information"
  # @a:contract {"requires":[],"ensures":["renders static_pages/contact template"]}
  # @a:io {"input":null,"output":{"status":"200","template":"static_pages/contact"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Public"
  # @a:perf "Static render"
  # @a:dependencies []
  # @a:example {"ok":"GET /contact","ng":"POST /contact -> no route"}
  # @a:cases ["TEST-static-contact-route"]
  def contact
  end
end
