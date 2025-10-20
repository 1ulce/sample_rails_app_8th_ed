require "test_helper"

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  # @t:id "TEST-relationship-validations-basics"
  # @t:covers ["app/models/relationship.rb#Relationship"]
  # @t:intent "Valid relationship with follower and followed users persists"
  # @t:kind "unit"
  test "should be valid" do
    assert @relationship.valid?
  end

  # @t:id "TEST-relationship-follower-required"
  # @t:covers ["app/models/relationship.rb#Relationship"]
  # @t:intent "Relationship requires follower_id"
  # @t:kind "unit"
  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  # @t:id "TEST-relationship-followed-required"
  # @t:covers ["app/models/relationship.rb#Relationship"]
  # @t:intent "Relationship requires followed_id"
  # @t:kind "unit"
  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
