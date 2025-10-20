# @a:id "app/models/user.rb#User"
# @a:summary "User domain model for authentication, activation, and social graph features"
# @a:intent "Persist users with secure credentials and expose helpers for session, activation, reset, and follow relationships"
# @a:contract {"requires":["valid name/email/password attributes for persistence"],"ensures":["remember/reset/activation digests stay consistent with tokens","following links enforce referential integrity"]}
# @a:io {"input":{"attributes":"Hash-like params from controllers/jobs"},"output":{"record":"ActiveRecord::PersistenceResult"}}
# @a:errors ["ActiveRecord::RecordInvalid","ActiveRecord::RecordNotFound"]
# @a:sideEffects "Touches users, microposts, relationships tables; triggers outbound email via UserMailer"
# @a:security "Hashes all sensitive tokens and enforces password validations; relies on controller filters for access control"
# @a:perf "AR validations O(1) per attribute; feed query O(n) by followers count with SQL include"
# @a:dependencies ["BCrypt::Password","SecureRandom","UserMailer","Micropost","Relationship","ActiveRecord::Callbacks"]
# @a:example {"ok":"User.create!(name:\"Taro\", email:\"taro@example.jp\", password:\"foobar\", password_confirmation:\"foobar\")","ng":"User.create!(name:\"\", email:\"invalid\", password:\"foo\", password_confirmation:\"bar\") # raises ActiveRecord::RecordInvalid"}
# @a:cases ["TEST-user-validations-basics","TEST-users-signup-activation-flow","TEST-user-follow-graph","TEST-user-feed-follows","TEST-user-email-downcase","TEST-password-reset-expiry"]
class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # @a:id "app/models/user.rb#User.digest"
  # @a:summary "Generate a bcrypt digest for password-like secrets using environment-appropriate cost"
  # @a:intent "Provide deterministic hashing for remember/reset tokens and fixtures"
  # @a:contract {"requires":["string.is_a?(String)","string.present?"],"ensures":["returns bcrypt hash with configured cost"]}
  # @a:io {"input":{"string":"String"},"output":{"digest":"String (bcrypt hash)"}}
  # @a:errors ["ArgumentError when string is nil"]
  # @a:sideEffects "none"
  # @a:security "Never log digests; relies on bcrypt cost tuning via ActiveModel::SecurePassword.min_cost"
  # @a:perf "O(cost) bcrypt hashing (~100ms production, minimal in tests)"
  # @a:dependencies ["BCrypt::Password","ActiveModel::SecurePassword.min_cost"]
  # @a:example {"ok":"User.digest(\"secret\") #=> \"$2a$12$...\"","ng":"User.digest(nil) # ArgumentError"}
  # @a:cases []
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # @a:id "app/models/user.rb#User.new_token"
  # @a:summary "Generate a URL-safe random token for authentication flows"
  # @a:intent "Issue unpredictable tokens for remember, activation, and reset digests"
  # @a:contract {"requires":[],"ensures":["returns 22-char base64url token with ≥128 bits entropy"]}
  # @a:io {"input":null,"output":{"token":"String"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Uses SecureRandom.urlsafe_base64; safe for cookies/email links"
  # @a:perf "O(1)"
  # @a:dependencies ["SecureRandom"]
  # @a:example {"ok":"User.new_token #=> \"d8C1O8l6o2hBvFSpJ6y7ZA\"","ng":"(n/a)"}
  # @a:cases ["TEST-mailer-account-activation","TEST-mailer-password-reset"]
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # @a:id "app/models/user.rb#remember"
  # @a:summary "Persist a remember digest so cookies can authenticate without credentials"
  # @a:intent "Maintain long-lived session token hashed server-side"
  # @a:contract {"requires":["persisted? == true"],"ensures":["remember_digest stores bcrypt hash of new remember_token","remember_token is accessible until overwritten"]}
  # @a:io {"input":null,"output":{"digest":"String"}}
  # @a:errors ["ActiveRecord::ActiveRecordError when update fails"]
  # @a:sideEffects "Updates remember_digest column; mutates remember_token accessor"
  # @a:security "Token never stored in DB; caller must guard cookie exposure"
  # @a:perf "Single update SQL"
  # @a:dependencies ["User.digest","update_attribute"]
  # @a:example {"ok":"user.remember #=> \"$2a$12$...\" and sets remember_token","ng":"User.new.remember # raises ActiveRecord::NotSaved"}
  # @a:cases ["TEST-users-login-remember-cookie","TEST-users-login-forget-cookie"]
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # @a:id "app/models/user.rb#session_token"
  # @a:summary "Return the persisted remember digest, creating one if missing"
  # @a:intent "Provide stable server-side token for verifying remember cookie"
  # @a:contract {"requires":["persisted? == true"],"ensures":["returns remember_digest","creates remember_digest when absent"]}
  # @a:io {"input":null,"output":{"token":"String"}}
  # @a:errors ["ActiveRecord::ActiveRecordError when remember update fails"]
  # @a:sideEffects "Calls remember when digest absent (DB write)"
  # @a:security "Digest remains hashed; caller compares hashed value only"
  # @a:perf "O(1) read with optional single update"
  # @a:dependencies ["remember"]
  # @a:example {"ok":"user.session_token #=> \"$2a$12$...\"","ng":"User.new.session_token # raises ActiveRecord::NotSaved"}
  # @a:cases ["TEST-users-login-remember-cookie","TEST-users-login-forget-cookie"]
  def session_token
    remember_digest || remember
  end

  # @a:id "app/models/user.rb#authenticated?"
  # @a:summary "Compare supplied token against stored digest attribute"
  # @a:intent "Support multiple digest-backed flows (remember, activation, reset)"
  # @a:contract {"requires":["attribute corresponds to *_digest column"],"ensures":["returns true when token matches digest","returns false when digest missing or mismatch"]}
  # @a:io {"input":{"attribute":"String","token":"String"},"output":{"authenticated":"Boolean"}}
  # @a:errors ["ArgumentError when attribute does not map to method"]
  # @a:sideEffects "none"
  # @a:security "Timing-safe bcrypt comparison; rejects nil digests up front"
  # @a:perf "O(cost) bcrypt comparison"
  # @a:dependencies ["BCrypt::Password","send"]
  # @a:example {"ok":"user.authenticated?(:remember, token) #=> true when digest matches","ng":"user.authenticated?(:remember, \"wrong\") #=> false"}
  # @a:cases ["TEST-user-authenticated-nil-digest","TEST-users-login-remember-cookie","TEST-users-login-forget-cookie","TEST-users-signup-activation-flow","TEST-users-signup-activation-blocked","TEST-users-activation-invalid-token","TEST-users-activation-invalid-email","TEST-password-reset-token-validation"]
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # @a:id "app/models/user.rb#forget"
  # @a:summary "Clear the remember digest to invalidate persistent sessions"
  # @a:intent "Force re-authentication after logout or credential reset"
  # @a:contract {"requires":["persisted? == true"],"ensures":["remember_digest becomes nil"]}
  # @a:io {"input":null,"output":{"result":"Boolean"}}
  # @a:errors ["ActiveRecord::ActiveRecordError when update fails"]
  # @a:sideEffects "Updates remember_digest to nil"
  # @a:security "Removes ability to reuse cookie-based login"
  # @a:perf "Single update SQL"
  # @a:dependencies ["update_attribute"]
  # @a:example {"ok":"user.forget #=> true and clears remember_digest","ng":"User.new.forget # raises ActiveRecord::NotSaved"}
  # @a:cases ["TEST-users-login-remember-cookie","TEST-users-login-forget-cookie"]
  def forget
    update_attribute(:remember_digest, nil)
  end

  # @a:id "app/models/user.rb#activate"
  # @a:summary "Mark the user as activated and timestamp activation"
  # @a:intent "Complete signup flow after valid email confirmation"
  # @a:contract {"requires":["persisted? == true"],"ensures":["activated == true","activated_at set to Time.zone.now"]}
  # @a:io {"input":null,"output":{"result":"Boolean"}}
  # @a:errors ["ActiveRecord::ActiveRecordError when updates fail"]
  # @a:sideEffects "Writes activated flag and timestamp"
  # @a:security "Should only be called after token verification"
  # @a:perf "Two update_attribute calls"
  # @a:dependencies ["update_attribute","Time.zone"]
  # @a:example {"ok":"user.activate #=> true and sets activated_at","ng":"User.new.activate # raises ActiveRecord::NotSaved"}
  # @a:cases ["TEST-users-signup-activation-success"]
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # @a:id "app/models/user.rb#send_activation_email"
  # @a:summary "Queue an immediate account activation email for the user"
  # @a:intent "Deliver activation instructions after signup"
  # @a:contract {"requires":["activation_token present","email present"],"ensures":["mail delivered via UserMailer.account_activation"]}
  # @a:io {"input":null,"output":{"delivery":"Mail::Message"}}
  # @a:errors ["Net::SMTPError when delivery fails"]
  # @a:sideEffects "Enqueues synchronous email delivery"
  # @a:security "Token embedded in email; ensure TLS when sending"
  # @a:perf "Network-bound; synchronous deliver_now"
  # @a:dependencies ["UserMailer.account_activation","ActionMailer::DeliveryJob"]
  # @a:example {"ok":"user.send_activation_email #=> Mail::Message","ng":"User.new.send_activation_email # raises NoMethodError on nil email"}
  # @a:cases ["TEST-mailer-account-activation","TEST-users-signup-activation-flow","TEST-users-signup-activation-success"]
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # @a:id "app/models/user.rb#create_reset_digest"
  # @a:summary "Issue a fresh reset token and digest with timestamp for password recovery"
  # @a:intent "Prepare user for password reset email workflow"
  # @a:contract {"requires":["persisted? == true"],"ensures":["reset_token accessor set","reset_digest hashed from token","reset_sent_at within current timestamp"]}
  # @a:io {"input":null,"output":{"token":"String"}}
  # @a:errors ["ActiveRecord::ActiveRecordError when update fails"]
  # @a:sideEffects "Writes reset_digest and reset_sent_at; mutates reset_token"
  # @a:security "Digest stored, token ephemeral; short expiry enforced by password_reset_expired?"
  # @a:perf "Two update_attribute calls"
  # @a:dependencies ["User.new_token","User.digest","Time.zone"]
  # @a:example {"ok":"user.create_reset_digest #=> token string","ng":"User.new.create_reset_digest # raises ActiveRecord::NotSaved"}
  # @a:cases ["TEST-password-reset-request-updates","TEST-mailer-password-reset"]
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # @a:id "app/models/user.rb#send_password_reset_email"
  # @a:summary "Send password reset instructions to the user"
  # @a:intent "Deliver reset link after create_reset_digest"
  # @a:contract {"requires":["reset_token present","email present"],"ensures":["mail delivered via UserMailer.password_reset"]}
  # @a:io {"input":null,"output":{"delivery":"Mail::Message"}}
  # @a:errors ["Net::SMTPError when delivery fails"]
  # @a:sideEffects "Enqueues synchronous email delivery"
  # @a:security "Reset token in email; short expiry enforced elsewhere"
  # @a:perf "Network-bound; synchronous deliver_now"
  # @a:dependencies ["UserMailer.password_reset"]
  # @a:example {"ok":"user.create_reset_digest && user.send_password_reset_email","ng":"user.send_password_reset_email without digest # may email stale token"}
  # @a:cases ["TEST-mailer-password-reset","TEST-password-reset-request-updates"]
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # @a:id "app/models/user.rb#password_reset_expired?"
  # @a:summary "Check whether reset token is older than two hours"
  # @a:intent "Prevent reuse of stale password reset links"
  # @a:contract {"requires":["reset_sent_at present"],"ensures":["returns true when sent_at < 2 hours ago","returns false otherwise"]}
  # @a:io {"input":null,"output":{"expired":"Boolean"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Enforces short-lived reset window"
  # @a:perf "O(1)"
  # @a:dependencies ["Time.zone"]
  # @a:example {"ok":"user.reset_sent_at = 3.hours.ago; user.password_reset_expired? #=> true","ng":"user.reset_sent_at = 1.hour.ago; ... #=> false"}
  # @a:cases ["TEST-password-reset-expiry"]
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # @a:id "app/models/user.rb#feed"
  # @a:summary "Return microposts from the user and followed accounts"
  # @a:intent "Provide timeline query with eager loading for UI"
  # @a:contract {"requires":["persisted? == true"],"ensures":["includes own microposts","includes followed users' posts"]}
  # @a:io {"input":null,"output":{"relation":"ActiveRecord::Relation<Micropost>"}}
  # @a:errors []
  # @a:sideEffects "Builds SQL with subquery; no writes"
  # @a:security "Scope restricted to accessible posts"
  # @a:perf "Single query with subselect; relies on DB index on relationships"
  # @a:dependencies ["Relationship","Micropost.includes","ActiveStorage"]
  # @a:example {"ok":"user.feed.where(user: user).exists?","ng":"user.feed.where(user: unfollowed).exists? #=> false"}
  # @a:cases ["TEST-user-feed-follows"]
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
             .includes(:user, image_attachment: :blob)
  end

  # @a:id "app/models/user.rb#follow"
  # @a:summary "Create following relationship to another user"
  # @a:intent "Allow social graph connections"
  # @a:contract {"requires":["other_user.is_a?(User)"],"ensures":["following includes other_user unless self"]}
  # @a:io {"input":{"other_user":"User"},"output":{"relation":"Relationship"}}
  # @a:errors ["ActiveRecord::RecordInvalid when validation fails"]
  # @a:sideEffects "Inserts into relationships table"
  # @a:security "Prevents self-follow at call site"
  # @a:perf "Single insert"
  # @a:dependencies ["active_relationships"]
  # @a:example {"ok":"michael.follow(archer)","ng":"michael.follow(michael) # no-op"}
  # @a:cases ["TEST-user-follow-graph"]
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # @a:id "app/models/user.rb#unfollow"
  # @a:summary "Remove following relationship to another user"
  # @a:intent "Allow users to stop following others"
  # @a:contract {"requires":["other_user.is_a?(User)"],"ensures":["following no longer includes other_user"]}
  # @a:io {"input":{"other_user":"User"},"output":{"result":"Relationship|nil"}}
  # @a:errors []
  # @a:sideEffects "Deletes from relationships join table"
  # @a:security "Only affects current user's relationships"
  # @a:perf "Single delete"
  # @a:dependencies ["following"]
  # @a:example {"ok":"michael.unfollow(archer)","ng":"michael.unfollow(michael) # no-op"}
  # @a:cases ["TEST-user-follow-graph"]
  def unfollow(other_user)
    following.delete(other_user)
  end

  # @a:id "app/models/user.rb#following?"
  # @a:summary "Check whether current user follows the given user"
  # @a:intent "Provide predicate for UI logic and policy checks"
  # @a:contract {"requires":["other_user.is_a?(User)"],"ensures":["returns true iff following includes other_user"]}
  # @a:io {"input":{"other_user":"User"},"output":{"following":"Boolean"}}
  # @a:errors []
  # @a:sideEffects "none"
  # @a:security "Read-only; no sensitive output"
  # @a:perf "Uses association cached collection (may hit DB first call)"
  # @a:dependencies ["following"]
  # @a:example {"ok":"michael.following?(archer) #=> true","ng":"michael.following?(users(:malory)) #=> false"}
  # @a:cases ["TEST-user-follow-graph"]
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # @a:id "app/models/user.rb#downcase_email"
    # @a:summary "Normalize email casing before persistence"
    # @a:intent "Guarantee emails are stored lowercase for uniqueness"
    # @a:contract {"requires":["email present"],"ensures":["email equals email.downcase"]}
    # @a:io {"input":null,"output":{"email":"String"}}
    # @a:errors []
    # @a:sideEffects "Mutates self.email attribute"
    # @a:security "Avoids case-sensitive duplicates; no PII leakage"
    # @a:perf "O(length of email)"
    # @a:dependencies []
    # @a:example {"ok":"self.email = \"Foo@Bar.com\"; downcase_email; email == \"foo@bar.com\"","ng":"self.email = nil; downcase_email # NoMethodError"}
    # @a:cases ["TEST-user-email-downcase"]
    def downcase_email
      self.email = email.downcase
    end

    # @a:id "app/models/user.rb#create_activation_digest"
    # @a:summary "Generate activation token and digest before user creation"
    # @a:intent "Prepare new users for activation email workflow"
    # @a:contract {"requires":["new_record? == true"],"ensures":["activation_token accessor set","activation_digest hashed from token"]}
    # @a:io {"input":null,"output":{"token":"String"}}
    # @a:errors []
    # @a:sideEffects "Mutates activation_token accessor; sets activation_digest attribute"
    # @a:security "Digest stored; token ephemeral"
    # @a:perf "O(1) with bcrypt hashing"
    # @a:dependencies ["User.new_token","User.digest"]
    # @a:example {"ok":"user.send(:create_activation_digest) sets token/digest before save","ng":"already persisted user callback rerun manually # resets digest unexpectedly"}
    # @a:cases ["TEST-users-signup-activation-flow","TEST-users-activation-inactive-default"]
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
