require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  # @t:id "TEST-user-validations-basics"
  # @t:covers ["app/models/user.rb#User"]
  # @t:intent "Baseline fixture validates with default attributes"
  # @t:kind "unit"
  test "should be valid" do
    assert @user.valid?
  end

  # @t:id "TEST-user-name-presence"
  # @t:covers ["app/models/user.rb#User"]
  # @t:intent "Reject missing name"
  # @t:kind "unit"
  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  # @t:id "TEST-user-email-presence"
  # @t:covers ["app/models/user.rb#User"]
  # @t:intent "Reject missing email"
  # @t:kind "unit"
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  # @t:id "TEST-user-authenticated-nil-digest"
  # @t:covers ["app/models/user.rb#authenticated?"]
  # @t:intent "Ensure nil digest returns false without raising"
  # @t:kind "unit"
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  # @t:id "TEST-user-email-downcase"
  # @t:covers ["app/models/user.rb#downcase_email","app/models/user.rb#User"]
  # @t:intent "Emails persist in lowercase regardless of input casing"
  # @t:kind "unit"
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save!
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  # @t:id "TEST-user-follow-graph"
  # @t:covers ["app/models/user.rb#follow","app/models/user.rb#unfollow","app/models/user.rb#following?"]
  # @t:intent "Follow relationships add/remove correctly and disallow self-follow"
  # @t:kind "unit"
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
    # Users can't follow themselves.
    michael.follow(michael)
    assert_not michael.following?(michael)
  end

  # @t:id "TEST-user-feed-follows"
  # @t:covers ["app/models/user.rb#feed"]
  # @t:intent "Feed contains self and followed posts but not unfollowed"
  # @t:kind "unit"
  test "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # Self-posts for user with followers
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # Self-posts for user with no followers
    archer.microposts.each do |post_self|
      assert archer.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end

  # @t:id "TEST-password-reset-expiry"
  # @t:covers ["app/models/user.rb#password_reset_expired?"]
  # @t:intent "Reset tokens expire after two hours"
  # @t:kind "unit"
  test "password reset expires after two hours" do
    @user.reset_sent_at = 3.hours.ago
    assert @user.password_reset_expired?
    @user.reset_sent_at = 1.hour.ago
    assert_not @user.password_reset_expired?
  end
end
