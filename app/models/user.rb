class User < ActiveRecord::Base
  has_secure_password
  
  # Associations
  has_many :polls, foreign_key: 'organizer_id'
  has_many :votes
  has_many :activities
  has_many :comments
  
  # Validations
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ['admin', 'organizer', 'voter'] }
  
  # Callbacks
  before_save :log_activity
  
  private
  
  def log_activity
    return unless self.changed?
    
    if self.new_record?
      activity_type = 'user_created'
    else
      activity_type = 'user_updated'
    end
    
    Activity.create(
      user_id: self.id,
      activity_type: activity_type,
      details: "User #{self.username} #{self.new_record? ? 'created' : 'updated'}"
    )
  end
end 