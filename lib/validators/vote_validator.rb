# Vote validation class
class VoteValidator
  include ActiveModel::Validations
  
  attr_accessor :user_id, :option_id, :question_id
  
  validates :user_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :option_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :question_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  validate :user_exists
  validate :option_exists
  validate :question_exists
  validate :option_belongs_to_question
  validate :poll_is_active
  validate :user_has_not_voted_for_single_choice
  validate :user_has_not_voted_for_same_option
  
  def initialize(attributes = {})
    @user_id = attributes[:user_id]
    @option_id = attributes[:option_id]
    @question_id = attributes[:question_id]
  end
  
  private
  
  def user_exists
    return if user_id.blank?
    
    unless User.exists?(user_id)
      errors.add(:user_id, "must reference an existing user")
    end
  end
  
  def option_exists
    return if option_id.blank?
    
    unless Option.exists?(option_id)
      errors.add(:option_id, "must reference an existing option")
    end
  end
  
  def question_exists
    return if question_id.blank?
    
    unless Question.exists?(question_id)
      errors.add(:question_id, "must reference an existing question")
    end
  end
  
  def option_belongs_to_question
    return if option_id.blank? || question_id.blank?
    
    option = Option.find_by(id: option_id)
    if option&.question_id != question_id.to_i
      errors.add(:option_id, "must belong to the specified question")
    end
  end
  
  def poll_is_active
    return if question_id.blank?
    
    question = Question.includes(:poll).find_by(id: question_id)
    unless question&.poll&.active?
      errors.add(:question_id, "cannot vote on questions in inactive polls")
    end
  end
  
  def user_has_not_voted_for_single_choice
    return if user_id.blank? || question_id.blank?
    
    question = Question.find_by(id: question_id)
    if question&.single_choice?
      existing_vote = Vote.where(user_id: user_id, question_id: question_id).exists?
      if existing_vote
        errors.add(:user_id, "has already voted on this single choice question")
      end
    end
  end
  
  def user_has_not_voted_for_same_option
    return if user_id.blank? || option_id.blank?
    
    existing_vote = Vote.where(user_id: user_id, option_id: option_id).exists?
    if existing_vote
      errors.add(:option_id, "user has already voted for this option")
    end
  end
end 