# Poll validation class
class PollValidator
  include ActiveModel::Validations
  
  attr_accessor :title, :description, :start_date, :end_date, :status, :organizer_id, :private
  
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true, inclusion: { in: ['draft', 'active', 'closed'] }
  validates :organizer_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :private, inclusion: { in: [true, false] }
  
  validate :end_date_after_start_date
  validate :start_date_not_in_past_for_active_polls
  validate :end_date_not_in_past_for_active_polls
  validate :organizer_exists
  
  def initialize(attributes = {})
    @title = attributes[:title]
    @description = attributes[:description]
    @start_date = attributes[:start_date]
    @end_date = attributes[:end_date]
    @status = attributes[:status]
    @organizer_id = attributes[:organizer_id]
    @private = attributes[:private] || false
  end
  
  private
  
  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end
  
  def start_date_not_in_past_for_active_polls
    return if start_date.blank? || status != 'active'
    
    if start_date < Date.current
      errors.add(:start_date, "cannot be in the past for active polls")
    end
  end
  
  def end_date_not_in_past_for_active_polls
    return if end_date.blank? || status != 'active'
    
    if end_date < Date.current
      errors.add(:end_date, "cannot be in the past for active polls")
    end
  end
  
  def organizer_exists
    return if organizer_id.blank?
    
    unless User.exists?(organizer_id)
      errors.add(:organizer_id, "must reference an existing user")
    end
  end
end 