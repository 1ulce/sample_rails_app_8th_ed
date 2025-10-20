require "test_helper"

class UsersHelperTest < ActionView::TestCase

  # @t:id "TEST-users-gravatar-helper"
  # @t:covers ["app/helpers/users_helper.rb#gravatar_for"]
  # @t:intent "Gravatar helper renders https image with requested size"
  # @t:kind "unit"
  test "gravatar_for builds correct image tag" do
    user = users(:michael)
    html = gravatar_for(user, size: 40)
    assert_includes html, "https://secure.gravatar.com/avatar"
    assert_includes html, "s=40"
    assert_includes html, "alt=\"#{user.name}\""
    assert_includes html, "class=\"gravatar\""
  end
end
