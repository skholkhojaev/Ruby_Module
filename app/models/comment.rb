class Comment < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :poll
  
  # Validations
  validates :content, presence: true
  
  # Scopes
  scope :by_poll, ->(poll_id) { where(poll_id: poll_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :latest, -> { order(created_at: :desc) }
  
  # Callbacks
  after_create :log_activity
  
  private
  
  def log_activity
    Activity.create(
      user_id: self.user_id,
      activity_type: 'comment_created',
      details: "Comment added to poll: #{self.poll.title}"
    )
  end
end 