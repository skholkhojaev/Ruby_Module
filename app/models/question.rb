class Question < ActiveRecord::Base
  # Associations
  belongs_to :poll
  has_many :options, dependent: :destroy
  has_many :votes, through: :options
  
  # Validations
  validates :text, presence: true
  validates :question_type, presence: true, inclusion: { in: ['single_choice', 'multiple_choice'] }
  
  # Scopes
  scope :by_poll, ->(poll_id) { where(poll_id: poll_id) }
  
  # Custom methods
  def single_choice?
    self.question_type == 'single_choice'
  end
  
  def multiple_choice?
    self.question_type == 'multiple_choice'
  end
  
  def results
    results = {}
    self.options.each do |option|
      results[option.text] = option.votes.count
    end
    results
  end
end 