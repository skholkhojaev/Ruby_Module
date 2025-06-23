# Comment validation class
class CommentValidator
  include ActiveModel::Validations
  
  attr_accessor :user_id, :poll_id, :content
  
  validates :user_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :poll_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  
  validate :user_exists
  validate :poll_exists
  validate :poll_not_private_or_user_has_access
  validate :content_not_empty_after_stripping
  
  def initialize(attributes = {})
    @user_id = attributes[:user_id]
    @poll_id = attributes[:poll_id]
    @content = attributes[:content]
  end
  
  private
  
  def user_exists
    return if user_id.blank?
    
    unless User.exists?(user_id)
      errors.add(:user_id, "must reference an existing user")
    end
  end
  
  def poll_exists
    return if poll_id.blank?
    
    unless Poll.exists?(poll_id)
      errors.add(:poll_id, "must reference an existing poll")
    end
  end
  
  def poll_not_private_or_user_has_access
    return if poll_id.blank? || user_id.blank?
    
    poll = Poll.find_by(id: poll_id)
    if poll&.private? && poll.organizer_id != user_id.to_i
      errors.add(:poll_id, "cannot comment on private polls unless you are the organizer")
    end
  end
  
  def content_not_empty_after_stripping
    return if content.blank?
    
    if content.strip.empty?
      errors.add(:content, "cannot be empty or contain only whitespace")
    end
  end
end 