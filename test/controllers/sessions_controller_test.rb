require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # @t:id "TEST-sessions-new-route"
  # @t:covers ["app/controllers/sessions_controller.rb#new","config/routes.rb#sessions"]
  # @t:intent "Login path responds successfully"
  # @t:kind "integration"
  test "should get new" do
    get login_path
    assert_response :success
  end
end
