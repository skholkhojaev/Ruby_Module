# Option validation class
class OptionValidator
  include ActiveModel::Validations
  
  attr_accessor :question_id, :text
  
  validates :question_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :text, presence: true, length: { maximum: 255 }
  
  validate :question_exists
  validate :question_not_in_closed_poll
  validate :unique_text_per_question
  
  def initialize(attributes = {})
    @question_id = attributes[:question_id]
    @text = attributes[:text]
  end
  
  private
  
  def question_exists
    return if question_id.blank?
    
    unless Question.exists?(question_id)
      errors.add(:question_id, "must reference an existing question")
    end
  end
  
  def question_not_in_closed_poll
    return if question_id.blank?
    
    question = Question.includes(:poll).find_by(id: question_id)
    if question&.poll&.closed?
      errors.add(:question_id, "cannot add options to questions in closed polls")
    end
  end
  
  def unique_text_per_question
    return if question_id.blank? || text.blank?
    
    existing_option = Option.where(question_id: question_id, text: text.strip)
    if existing_option.exists?
      errors.add(:text, "must be unique within the question")
    end
  end
end 