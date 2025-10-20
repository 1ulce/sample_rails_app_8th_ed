require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  # @t:id "TEST-microposts-create-auth"
  # @t:covers ["app/controllers/microposts_controller.rb#create"]
  # @t:intent "Unauthenticated users cannot create microposts"
  # @t:kind "integration"
  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  # @t:id "TEST-microposts-destroy-auth"
  # @t:covers ["app/controllers/microposts_controller.rb#destroy"]
  # @t:intent "Unauthenticated users cannot delete microposts"
  # @t:kind "integration"
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  # @t:id "TEST-microposts-destroy-ownership"
  # @t:covers ["app/controllers/microposts_controller.rb#destroy","app/controllers/microposts_controller.rb#correct_user"]
  # @t:intent "Users cannot delete microposts they do not own"
  # @t:kind "integration"
  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
  	micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
