require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  # @t:id "TEST-static-home-route"
  # @t:covers ["config/routes.rb#root","config/routes.rb#Routes"]
  # @t:intent "Root path renders home page successfully"
  # @t:kind "integration"
  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end

  # @t:id "TEST-static-help-route"
  # @t:covers ["config/routes.rb#static_pages","config/routes.rb#Routes"]
  # @t:intent "Help path resolves and renders expected title"
  # @t:kind "integration"
  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end

  # @t:id "TEST-static-about-route"
  # @t:covers ["config/routes.rb#static_pages","config/routes.rb#Routes"]
  # @t:intent "About path resolves and renders expected title"
  # @t:kind "integration"
  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

  # @t:id "TEST-static-contact-route"
  # @t:covers ["config/routes.rb#static_pages","config/routes.rb#Routes"]
  # @t:intent "Contact path resolves and renders expected title"
  # @t:kind "integration"
  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | Ruby on Rails Tutorial Sample App"
  end
end
