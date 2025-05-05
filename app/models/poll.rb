class Poll < ActiveRecord::Base
  # Associations
  belongs_to :organizer, class_name: 'User'
  has_many :questions, dependent: :destroy
  has_many :votes, through: :questions
  has_many :comments, dependent: :destroy
  
  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: ['draft', 'active', 'closed'] }
  validates :start_date, presence: true
  validates :end_date, presence: true
  
  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :draft, -> { where(status: 'draft') }
  scope :closed, -> { where(status: 'closed') }
  scope :by_organizer, ->(user_id) { where(organizer_id: user_id) }
  
  # Callbacks
  before_save :log_activity
  
  # Custom methods
  def active?
    self.status == 'active'
  end
  
  def closed?
    self.status == 'closed'
  end
  
  def total_votes
    self.votes.count
  end
  
  def close_poll
    self.update(status: 'closed')
  end
  
  private
  
  def log_activity
    return unless self.changed?
    
    if self.new_record?
      activity_type = 'poll_created'
    else
      activity_type = 'poll_updated'
    end
    
    Activity.create(
      user_id: self.organizer_id,
      activity_type: activity_type,
      details: "Poll #{self.title} #{self.new_record? ? 'created' : 'updated'}"
    )
  end
end 