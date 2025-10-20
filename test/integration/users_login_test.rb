require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin

  # @t:id "TEST-sessions-new-template"
  # @t:covers ["app/controllers/sessions_controller.rb#new","config/routes.rb#sessions"]
  # @t:intent "Login page renders new session template"
  # @t:kind "integration"
  test "login path" do
    get login_path
    assert_template 'sessions/new'
  end

  # @t:id "TEST-sessions-invalid-login"
  # @t:covers ["app/controllers/sessions_controller.rb#create","app/helpers/sessions_helper.rb#store_location"]
  # @t:intent "Invalid credentials re-render login with flash and do not log in"
  # @t:kind "integration"
  test "login with valid email/invalid password" do
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid" } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UsersLogin

  def setup
    super
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin

  # @t:id "TEST-sessions-valid-login"
  # @t:covers ["app/controllers/sessions_controller.rb#create","app/helpers/sessions_helper.rb#log_in"]
  # @t:intent "Successful login redirects to user profile"
  # @t:kind "integration"
  test "valid login" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  # @t:id "TEST-sessions-valid-login-nav"
  # @t:covers ["app/controllers/sessions_controller.rb#create","app/helpers/sessions_helper.rb#log_in","app/helpers/sessions_helper.rb#log_out"]
  # @t:intent "Navbar links update after login"
  # @t:kind "integration"
  test "redirect after login" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin

  def setup
    super
    delete logout_path
  end
end

class LogoutTest < Logout

  # @t:id "TEST-sessions-logout-success"
  # @t:covers ["app/controllers/sessions_controller.rb#destroy","app/helpers/sessions_helper.rb#log_out"]
  # @t:intent "Logout clears session and redirects to home"
  # @t:kind "integration"
  test "successful logout" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  # @t:id "TEST-sessions-logout-nav"
  # @t:covers ["app/controllers/sessions_controller.rb#destroy","app/helpers/sessions_helper.rb#log_out"]
  # @t:intent "Navbar reflects logged-out state after logout"
  # @t:kind "integration"
  test "redirect after logout" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # @t:id "TEST-sessions-logout-idempotent"
  # @t:covers ["app/controllers/sessions_controller.rb#destroy"]
  # @t:intent "Second logout request remains safe and redirects home"
  # @t:kind "integration"
  test "should still work after logout in second window" do
    delete logout_path
    assert_redirected_to root_url
  end
end

class RememberingTest < UsersLogin

  # @t:id "TEST-users-login-remember-cookie"
  # @t:covers ["app/models/user.rb#remember","app/models/user.rb#session_token","app/models/user.rb#authenticated?"]
  # @t:intent "Remember-me option persists cookie token"
  # @t:kind "integration"
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not cookies[:remember_token].blank?
  end

  # @t:id "TEST-users-login-forget-cookie"
  # @t:covers ["app/models/user.rb#forget","app/models/user.rb#remember"]
  # @t:intent "Disable remember-me clears cookie token"
  # @t:kind "integration"
  test "login without remembering" do
    # Log in to set the cookie.
    log_in_as(@user, remember_me: '1')
    # Log in again and verify that the cookie is deleted.
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end
