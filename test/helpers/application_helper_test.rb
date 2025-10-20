require "test_helper"

class ApplicationHelperTest < ActionView::TestCase

  # @t:id "TEST-application-full-title"
  # @t:covers ["app/helpers/application_helper.rb#full_title","app/helpers/application_helper.rb#ApplicationHelper"]
  # @t:intent "full_title returns base title or prefixed title when provided"
  # @t:kind "unit"
  test "full_title helper" do
    assert_equal "Ruby on Rails Tutorial Sample App", full_title
    assert_equal "Help | Ruby on Rails Tutorial Sample App", full_title("Help")
  end
end
