require "test_helper"

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  # @t:id "TEST-micropost-validations-basics"
  # @t:covers ["app/models/micropost.rb#Micropost"]
  # @t:intent "Baseline micropost with user and content is valid"
  # @t:kind "unit"
  test "should be valid" do
    assert @micropost.valid?
  end

  # @t:id "TEST-micropost-user-required"
  # @t:covers ["app/models/micropost.rb#Micropost"]
  # @t:intent "Micropost must belong to a user"
  # @t:kind "unit"
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  # @t:id "TEST-micropost-content-presence"
  # @t:covers ["app/models/micropost.rb#Micropost"]
  # @t:intent "Reject blank content"
  # @t:kind "unit"
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  # @t:id "TEST-micropost-content-length"
  # @t:covers ["app/models/micropost.rb#Micropost"]
  # @t:intent "Enforce maximum length of 140 characters"
  # @t:kind "unit"
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  # @t:id "TEST-micropost-default-scope-order"
  # @t:covers ["app/models/micropost.rb#Micropost"]
  # @t:intent "Default scope returns newest micropost first"
  # @t:kind "unit"
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
