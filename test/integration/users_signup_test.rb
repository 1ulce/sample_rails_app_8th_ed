require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup

  # @t:id "TEST-users-signup-invalid"
  # @t:covers ["app/controllers/users_controller.rb#create","app/models/user.rb#User"]
  # @t:intent "Reject invalid signup and re-render form"
  # @t:kind "integration"
  test "invalid signup information" do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  # @t:id "TEST-users-signup-activation-flow"
  # @t:covers ["app/controllers/users_controller.rb#create","app/models/user.rb#send_activation_email","app/models/user.rb#create_activation_digest"]
  # @t:intent "Successful signup sends activation email and keeps user pending"
  # @t:kind "integration"
  test "valid signup information with account activation" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end

class AccountActivationTest < UsersSignup

  def setup
    super
    post users_path, params: { user: { name:  "Example User",
                                       email: "user@example.com",
                                       password:              "password",
                                       password_confirmation: "password" } }
    @user = assigns(:user)
  end

  # @t:id "TEST-users-activation-inactive-default"
  # @t:covers ["app/models/user.rb#create_activation_digest","app/models/user.rb#activate"]
  # @t:intent "User remains inactive immediately after signup"
  # @t:kind "integration"
  test "should not be activated" do
    assert_not @user.activated?
  end

  # @t:id "TEST-users-signup-activation-blocked"
  # @t:covers ["app/models/user.rb#authenticated?"]
  # @t:intent "Login blocked until account activation completes"
  # @t:kind "integration"
  test "should not be able to log in before account activation" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  # @t:id "TEST-users-activation-invalid-token"
  # @t:covers ["app/models/user.rb#authenticated?"]
  # @t:intent "Activation fails with invalid token"
  # @t:kind "integration"
  test "should not be able to log in with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  # @t:id "TEST-users-activation-invalid-email"
  # @t:covers ["app/models/user.rb#authenticated?"]
  # @t:intent "Activation fails with incorrect email"
  # @t:kind "integration"
  test "should not be able to log in with invalid email" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  # @t:id "TEST-users-signup-activation-success"
  # @t:covers ["app/models/user.rb#activate","app/models/user.rb#authenticated?"]
  # @t:intent "Valid token activates account and logs in user"
  # @t:kind "integration"
  test "should log in successfully with valid activation token and email" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
