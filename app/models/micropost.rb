# @a:id "app/models/micropost.rb#Micropost"
# @a:summary "Micropost domain model handling short text updates with optional image attachments"
# @a:intent "Persist user-authored posts ordered by recency with validations on content and image uploads"
# @a:contract {"requires":["user reference present","content present and <=140 chars","image complies with content_type/size"],"ensures":["records order by created_at desc","image variants available for display"]}
# @a:io {"input":{"attributes":"{user: User, content: String, image: ActiveStorage::Blob?}"},"output":{"record":"Micropost"}}
# @a:errors ["ActiveRecord::RecordInvalid","ActiveRecord::RecordNotFound","ActiveStorage::IntegrityError"]
# @a:sideEffects "Writes to microposts table and ActiveStorage attachments; creates resize variant on demand"
# @a:security "Rejects non-image uploads and large files; inherits user-level authorization from controllers"
# @a:perf "Default scope sorts by created_at desc; image variant resize limited to 500x500 to cap processing"
# @a:dependencies ["ActiveRecord","ActiveStorage::Attached::One","Variant resizing","User"]
# @a:example {"ok":"users(:michael).microposts.create!(content:\"Hello\", image: fixture_file_upload(\"test/fixtures/files/kitten.png\", \"image/png\"))","ng":"users(:michael).microposts.create!(content:\"\", image:nil) # raises ActiveRecord::RecordInvalid"}
# @a:cases ["TEST-micropost-validations-basics","TEST-micropost-user-required","TEST-micropost-content-presence","TEST-micropost-content-length","TEST-micropost-default-scope-order"]
class Micropost < ApplicationRecord
  belongs_to       :user

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size: { less_than: 5.megabytes,
                              message:   "should be less than 5MB" }
end
