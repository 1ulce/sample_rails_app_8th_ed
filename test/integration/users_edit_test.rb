require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  # @t:id "TEST-users-update-validations"
  # @t:covers ["app/controllers/users_controller.rb#edit","app/controllers/users_controller.rb#update","app/models/user.rb#User"]
  # @t:intent "Invalid attributes re-render edit form"
  # @t:kind "integration"
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'
  end

  # @t:id "TEST-users-edit-authorization"
  # @t:covers ["app/controllers/users_controller.rb#edit","app/controllers/users_controller.rb#update"]
  # @t:intent "Friendly forwarding allows owner to edit successfully"
  # @t:kind "integration"
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
