# @a:id "config/routes.rb#Routes"
# @a:summary "HTTP routing table for static pages, authentication, user management, and social features"
# @a:intent "Expose canonical paths for controllers while keeping URL semantics stable for UI and API clients"
# @a:contract {"requires":["Rails.application.routes.draw context","unique path helpers for session login/logout"],"ensures":["root directs to StaticPages#home","named routes exist for help/about/contact","REST resources defined for users, account activations, password resets, microposts, relationships","legacy /microposts GET routes to home for pagination compatibility"]}
# @a:io {"input":{"request":"HTTP verb + path"},"output":{"dispatch":"controller#action per mapping"}}
# @a:errors []
# @a:sideEffects "Defines middleware dispatch table at boot"
# @a:security "Relies on controller-level before_action hooks (logged_in_user, admin_user, etc.)"
# @a:perf "Route set compiled at boot; minimal per-request overhead"
# @a:dependencies ["StaticPagesController","UsersController","SessionsController","AccountActivationsController","PasswordResetsController","MicropostsController","RelationshipsController"]
# @a:example {"ok":"GET /login -> SessionsController#new","ng":"POST /logout -> no route (should use DELETE)"}
# @a:cases ["TEST-static-home-route","TEST-static-help-route","TEST-static-about-route","TEST-static-contact-route","TEST-users-signup-invalid","TEST-users-login-remember-cookie","TEST-users-profile-feed","TEST-microposts-interface-crud","TEST-users-following-view"]
Rails.application.routes.draw do
  # @a:id "config/routes.rb#root"
  # @a:summary "Root path shows the home feed or signup CTA"
  # @a:intent "Default landing page for authenticated and guest users"
  # @a:contract {"requires":["root path lookup"],"ensures":["GET / dispatches to static_pages#home"]}
  # @a:io {"input":{"verb":"GET","path":"/"},"output":{"controller":"StaticPagesController","action":"home"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Home controller handles conditional feed rendering"
  # @a:perf "Static page render plus optional feed pagination"
  # @a:dependencies ["StaticPagesController#home"]
  # @a:example {"ok":"GET / -> renders home","ng":"POST / -> no route"}
  # @a:cases ["TEST-static-home-route","TEST-microposts-interface-crud"]
  root   "static_pages#home"

  # @a:id "config/routes.rb#static_pages"
  # @a:summary "Named helpers for help/about/contact informational pages"
  # @a:intent "Expose predictable URLs for marketing/navigation"
  # @a:contract {"requires":["GET requests"],"ensures":["/help maps to static_pages#help","/about maps to static_pages#about","/contact maps to static_pages#contact"]}
  # @a:io {"input":{"verb":"GET","path":"/help|/about|/contact"},"output":{"controller":"StaticPagesController","action":"help|about|contact"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Public content"
  # @a:perf "Static renders"
  # @a:dependencies ["StaticPagesController"]
  # @a:example {"ok":"GET /help -> StaticPagesController#help","ng":"POST /help -> no route"}
  # @a:cases ["TEST-static-help-route","TEST-static-about-route","TEST-static-contact-route"]
  get    "/help",   to: "static_pages#help"
  get    "/about",  to: "static_pages#about"
  get    "/contact",to: "static_pages#contact"

  # @a:id "config/routes.rb#signup"
  # @a:summary "Signup form entry point"
  # @a:intent "Expose friendly /signup path for UsersController#new"
  # @a:contract {"requires":["GET request"],"ensures":["/signup routes to users#new"]}
  # @a:io {"input":{"verb":"GET","path":"/signup"},"output":{"controller":"UsersController","action":"new"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Public; actual create path handles validation"
  # @a:perf "Form render"
  # @a:dependencies ["UsersController#new"]
  # @a:example {"ok":"GET /signup","ng":"POST /signup -> no route (use POST /users)"}
  # @a:cases ["TEST-users-signup-invalid"]
  get    "/signup", to: "users#new"

  # @a:id "config/routes.rb#sessions"
  # @a:summary "Named routes for login/logout cycle"
  # @a:intent "Provide semantic paths for session management"
  # @a:contract {"requires":["GET /login to sessions#new","POST /login to sessions#create","DELETE /logout to sessions#destroy"],"ensures":["Only listed verbs available"]}
  # @a:io {"input":{"verb":"GET|POST|DELETE","path":"/login|/logout"},"output":{"controller":"SessionsController","action":"new|create|destroy"}}
  # @a:errors []
  # @a:sideEffects "None at routing level"
  # @a:security "Controller enforces authentication and remember tokens"
  # @a:perf "Minimal"
  # @a:dependencies ["SessionsController"]
  # @a:example {"ok":"DELETE /logout","ng":"GET /logout -> no route"}
  # @a:cases ["TEST-users-login-remember-cookie","TEST-users-login-forget-cookie"]
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # @a:id "config/routes.rb#users"
  # @a:summary "RESTful users resource with member routes for social graph"
  # @a:intent "Support CRUD on users plus following/followers lists"
  # @a:contract {"requires":["resourceful routes"],"ensures":["/users standard routes","member GET /users/:id/following|followers to UsersController#following|followers"]}
  # @a:io {"input":{"verb":"REST verbs","path":"/users(...)"}, "output":{"controller":"UsersController","action":"index|show|new|create|edit|update|destroy|following|followers"}}
  # @a:errors []
  # @a:sideEffects "Defines 8 REST routes plus 2 member routes"
  # @a:security "Controller filters enforce login/admin"
  # @a:perf "Pagination for index/follow lists"
  # @a:dependencies ["UsersController"]
  # @a:example {"ok":"GET /users/1/followers","ng":"POST /users/1/followers -> no route"}
  # @a:cases ["TEST-users-index-auth","TEST-users-index-admin-list","TEST-users-followers-list","TEST-users-following-view","TEST-users-destroy-admin-only"]
  resources :users do
    member do
      get :following
      get :followers
    end
  end

  # @a:id "config/routes.rb#account_activations"
  # @a:summary "Expose activation token edit endpoint"
  # @a:intent "Allow users to activate accounts via emailed link"
  # @a:contract {"requires":["GET /account_activations/:id/edit"],"ensures":["dispatch to AccountActivationsController#edit only"]}
  # @a:io {"input":{"verb":"GET","path":"/account_activations/:id/edit"},"output":{"controller":"AccountActivationsController","action":"edit"}}
  # @a:errors []
  # @a:sideEffects "None at routing"
  # @a:security "Controller validates token/email"
  # @a:perf "O(1)"
  # @a:dependencies ["AccountActivationsController#edit"]
  # @a:example {"ok":"GET /account_activations/abc/edit","ng":"POST /account_activations -> no route"}
  # @a:cases ["TEST-users-signup-activation-success","TEST-users-activation-invalid-token"]
  resources :account_activations, only: [:edit]

  # @a:id "config/routes.rb#password_resets"
  # @a:summary "Routes for password reset request and completion"
  # @a:intent "Provide form endpoints for requesting and applying reset tokens"
  # @a:contract {"requires":["GET new","POST create","GET edit","PATCH/PUT update"],"ensures":["only listed actions exposed"]}
  # @a:io {"input":{"verb":"GET|POST|PATCH|PUT","path":"/password_resets(...)"}, "output":{"controller":"PasswordResetsController","action":"new|create|edit|update"}}
  # @a:errors []
  # @a:sideEffects "None"
  # @a:security "Controller enforces token and expiry"
  # @a:perf "O(1)"
  # @a:dependencies ["PasswordResetsController"]
  # @a:example {"ok":"POST /password_resets","ng":"DELETE /password_resets/1 -> no route"}
  # @a:cases ["TEST-password-reset-request-updates","TEST-password-reset-token-validation","TEST-password-reset-expiry"]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  # @a:id "config/routes.rb#microposts"
  # @a:summary "Authenticated create/destroy routes for microposts"
  # @a:intent "Allow posting and deleting status updates"
  # @a:contract {"requires":["POST /microposts -> create","DELETE /microposts/:id -> destroy"],"ensures":["no index/show routes"]}
  # @a:io {"input":{"verb":"POST|DELETE","path":"/microposts"},"output":{"controller":"MicropostsController","action":"create|destroy"}}
  # @a:errors []
  # @a:sideEffects "none at routing"
  # @a:security "Controller ensures login and ownership"
  # @a:perf "none"
  # @a:dependencies ["MicropostsController"]
  # @a:example {"ok":"DELETE /microposts/1","ng":"GET /microposts/1 -> no route"}
  # @a:cases ["TEST-microposts-create-auth","TEST-microposts-destroy-ownership","TEST-microposts-interface-crud"]
  resources :microposts,          only: [:create, :destroy]

  # @a:id "config/routes.rb#relationships"
  # @a:summary "Routes for follow/unfollow actions"
  # @a:intent "Enable creation and destruction of follow relationships"
  # @a:contract {"requires":["POST /relationships -> create","DELETE /relationships/:id -> destroy"],"ensures":["no index/show routes"]}
  # @a:io {"input":{"verb":"POST|DELETE","path":"/relationships"},"output":{"controller":"RelationshipsController","action":"create|destroy"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Controller checks logged-in user"
  # @a:perf "none"
  # @a:dependencies ["RelationshipsController"]
  # @a:example {"ok":"POST /relationships","ng":"GET /relationships -> no route"}
  # @a:cases ["TEST-users-following-view","TEST-users-followers-view","TEST-user-follow-graph"]
  resources :relationships,       only: [:create, :destroy]

  # @a:id "config/routes.rb#microposts-index-redirect"
  # @a:summary "Redirect legacy GET /microposts to home page"
  # @a:intent "Preserve pagination links for Turbo/Hotwire flows"
  # @a:contract {"requires":["GET /microposts"],"ensures":["dispatch to StaticPages#home for compatibility"]}
  # @a:io {"input":{"verb":"GET","path":"/microposts"},"output":{"controller":"StaticPagesController","action":"home"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Same as home route"
  # @a:perf "none"
  # @a:dependencies ["StaticPagesController#home"]
  # @a:example {"ok":"GET /microposts -> home","ng":"DELETE /microposts -> handled by resource route"}
  # @a:cases ["TEST-microposts-interface-crud"]
  get '/microposts', to: 'static_pages#home'
end
