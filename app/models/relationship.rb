# @a:id "app/models/relationship.rb#Relationship"
# @a:summary "Follow relationship join model between users"
# @a:intent "Persist follower-followed pairs and enforce presence of both sides"
# @a:contract {"requires":["follower_id present","followed_id present"],"ensures":["belongs_to associations resolve to User"]}
# @a:io {"input":{"attributes":"{follower: User, followed: User}"},"output":{"record":"Relationship"}}
# @a:errors ["ActiveRecord::RecordInvalid"]
# @a:sideEffects "Inserts/deletes rows in relationships table"
# @a:security "Authorization enforced at controller level"
# @a:perf "Simple presence validations; relies on DB indexes"
# @a:dependencies ["User","ApplicationRecord"]
# @a:example {"ok":"users(:michael).active_relationships.create!(followed: users(:archer))","ng":"Relationship.create!(follower:nil, followed:nil) # raises ActiveRecord::RecordInvalid"}
# @a:cases ["TEST-relationship-validations-basics","TEST-relationship-follower-required","TEST-relationship-followed-required","TEST-users-following-view","TEST-users-followers-view","TEST-user-follow-graph"]
class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
