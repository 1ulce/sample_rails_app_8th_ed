require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  # @t:id "TEST-users-index-admin-list"
  # @t:covers ["app/controllers/users_controller.rb#index","app/controllers/users_controller.rb#destroy","app/models/user.rb#User"]
  # @t:intent "Admins see paginated list with delete links and can remove users"
  # @t:kind "integration"
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  # @t:id "TEST-users-index-non-admin-no-delete"
  # @t:covers ["app/controllers/users_controller.rb#index"]
  # @t:intent "Non-admins cannot see delete links"
  # @t:kind "integration"
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
