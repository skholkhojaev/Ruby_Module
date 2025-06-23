# Question validation class
class QuestionValidator
  include ActiveModel::Validations
  
  attr_accessor :poll_id, :text, :question_type
  
  validates :poll_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :text, presence: true
  validates :question_type, presence: true, inclusion: { in: ['single_choice', 'multiple_choice'] }
  
  validate :poll_exists
  validate :poll_not_closed
  
  def initialize(attributes = {})
    @poll_id = attributes[:poll_id]
    @text = attributes[:text]
    @question_type = attributes[:question_type]
  end
  
  private
  
  def poll_exists
    return if poll_id.blank?
    
    unless Poll.exists?(poll_id)
      errors.add(:poll_id, "must reference an existing poll")
    end
  end
  
  def poll_not_closed
    return if poll_id.blank?
    
    poll = Poll.find_by(id: poll_id)
    if poll&.closed?
      errors.add(:poll_id, "cannot add questions to a closed poll")
    end
  end
end 