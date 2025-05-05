class Option < ActiveRecord::Base
  # Associations
  belongs_to :question
  has_many :votes
  
  # Validations
  validates :text, presence: true
  
  # Custom methods
  def vote_count
    self.votes.count
  end
  
  def vote_percentage
    total_votes = self.question.votes.count
    return 0 if total_votes == 0
    ((self.vote_count.to_f / total_votes) * 100).round(2)
  end
end 