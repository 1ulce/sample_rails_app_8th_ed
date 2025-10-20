require "test_helper"

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  # @t:id "TEST-sessions-helper-current-user"
  # @t:covers ["app/helpers/sessions_helper.rb#current_user","app/helpers/sessions_helper.rb#remember"]
  # @t:intent "current_user returns correct user when session is nil but remember cookie present"
  # @t:kind "unit"
  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # @t:id "TEST-sessions-helper-invalid-remember"
  # @t:covers ["app/helpers/sessions_helper.rb#current_user","app/helpers/sessions_helper.rb#forget"]
  # @t:intent "current_user returns nil when remember digest mismatches"
  # @t:kind "unit"
  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
