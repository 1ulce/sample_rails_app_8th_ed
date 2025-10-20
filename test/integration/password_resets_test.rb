require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class ForgotPasswordFormTest < PasswordResets

  # @t:id "TEST-password-reset-new-form"
  # @t:covers ["app/controllers/password_resets_controller.rb#new","config/routes.rb#password_resets"]
  # @t:intent "Render password reset request form"
  # @t:kind "integration"
  test "password reset path" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  # @t:id "TEST-password-reset-invalid-email"
  # @t:covers ["app/controllers/password_resets_controller.rb#create"]
  # @t:intent "Submitting unknown email re-renders form with error"
  # @t:kind "integration"
  test "reset path with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets

  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm

  # @t:id "TEST-password-reset-request-updates"
  # @t:covers ["app/models/user.rb#create_reset_digest","app/models/user.rb#send_password_reset_email"]
  # @t:intent "Successful reset request rotates digest and sends mail"
  # @t:kind "integration"
  test "reset with valid email" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  # @t:id "TEST-password-reset-form-wrong-email"
  # @t:covers ["app/controllers/password_resets_controller.rb#valid_user"]
  # @t:intent "Reset link rejects requests missing matching email parameter"
  # @t:kind "integration"
  test "reset with wrong email" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  # @t:id "TEST-password-reset-form-inactive"
  # @t:covers ["app/controllers/password_resets_controller.rb#valid_user"]
  # @t:intent "Inactive user cannot use reset link"
  # @t:kind "integration"
  test "reset with inactive user" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  # @t:id "TEST-password-reset-token-validation"
  # @t:covers ["app/models/user.rb#authenticated?"]
  # @t:intent "Reject reset when token does not match digest"
  # @t:kind "integration"
  test "reset with right email but wrong token" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  # @t:id "TEST-password-reset-form-valid-token"
  # @t:covers ["app/controllers/password_resets_controller.rb#edit","app/controllers/password_resets_controller.rb#valid_user"]
  # @t:intent "Valid token renders the reset form"
  # @t:kind "integration"
  test "reset with right email and right token" do
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm

  # @t:id "TEST-password-update-invalid-confirmation"
  # @t:covers ["app/controllers/password_resets_controller.rb#update"]
  # @t:intent "Mismatched confirmation re-renders edit form"
  # @t:kind "integration"
  test "update with invalid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  # @t:id "TEST-password-update-empty"
  # @t:covers ["app/controllers/password_resets_controller.rb#update"]
  # @t:intent "Empty password rejects update"
  # @t:kind "integration"
  test "update with empty password" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  # @t:id "TEST-password-update-success"
  # @t:covers ["app/controllers/password_resets_controller.rb#update","app/helpers/sessions_helper.rb#log_in"]
  # @t:intent "Valid password resets account and logs user in"
  # @t:kind "integration"
  test "update with valid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
  end
end
