require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  # @t:id "TEST-relationships-create-login-required"
  # @t:covers ["app/controllers/relationships_controller.rb#create","app/controllers/application_controller.rb#logged_in_user","config/routes.rb#relationships"]
  # @t:intent "Follow actions require authentication"
  # @t:kind "integration"
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end

  # @t:id "TEST-relationships-destroy-login-required"
  # @t:covers ["app/controllers/relationships_controller.rb#destroy","app/controllers/application_controller.rb#logged_in_user","config/routes.rb#relationships"]
  # @t:intent "Unfollow actions require authentication"
  # @t:kind "integration"
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
