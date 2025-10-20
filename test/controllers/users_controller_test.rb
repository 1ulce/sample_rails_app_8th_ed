
require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  # @t:id "TEST-users-signup-form"
  # @t:covers ["app/controllers/users_controller.rb#new"]
  # @t:intent "Signup route renders successfully"
  # @t:kind "integration"
  test "should get new" do
    get signup_path
    assert_response :success
  end

  # @t:id "TEST-users-index-auth"
  # @t:covers ["app/controllers/users_controller.rb#index"]
  # @t:intent "Unauthenticated users are redirected from index"
  # @t:kind "integration"
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  # @t:id "TEST-users-edit-login-required"
  # @t:covers ["app/controllers/users_controller.rb#edit"]
  # @t:intent "Must log in before editing profile"
  # @t:kind "integration"
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # @t:id "TEST-users-update-login-required"
  # @t:covers ["app/controllers/users_controller.rb#update"]
  # @t:intent "Update requires authentication"
  # @t:kind "integration"
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # @t:id "TEST-users-edit-wrong-user"
  # @t:covers ["app/controllers/users_controller.rb#correct_user","app/controllers/users_controller.rb#edit"]
  # @t:intent "Wrong user cannot load edit form"
  # @t:kind "integration"
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  # @t:id "TEST-users-update-wrong-user"
  # @t:covers ["app/controllers/users_controller.rb#correct_user","app/controllers/users_controller.rb#update"]
  # @t:intent "Wrong user cannot update profile"
  # @t:kind "integration"
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # @t:id "TEST-users-destroy-login-required"
  # @t:covers ["app/controllers/users_controller.rb#destroy"]
  # @t:intent "Destroy requires authentication"
  # @t:kind "integration"
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  # @t:id "TEST-users-destroy-admin-only"
  # @t:covers ["app/controllers/users_controller.rb#destroy","app/controllers/users_controller.rb#admin_user"]
  # @t:intent "Non-admin destroy attempt is blocked"
  # @t:kind "integration"
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  # @t:id "TEST-users-following-list"
  # @t:covers ["app/controllers/users_controller.rb#following"]
  # @t:intent "Must be logged in to view following list"
  # @t:kind "integration"
  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  # @t:id "TEST-users-followers-list"
  # @t:covers ["app/controllers/users_controller.rb#followers"]
  # @t:intent "Must be logged in to view followers list"
  # @t:kind "integration"
  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
