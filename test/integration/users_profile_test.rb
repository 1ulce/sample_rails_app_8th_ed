require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  # @t:id "TEST-users-profile-feed"
  # @t:covers ["app/controllers/users_controller.rb#show","app/models/user.rb#feed","app/helpers/users_helper.rb#gravatar_for"]
  # @t:intent "Profile page renders user info and timeline"
  # @t:kind "integration"
  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
