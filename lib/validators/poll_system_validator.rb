# Main validator module for the poll system
module PollSystemValidator
  class << self
    # Validate a poll
    def validate_poll(attributes)
      validator = PollValidator.new(attributes)
      validator.valid?
      validator
    end
    
    # Validate a question
    def validate_question(attributes)
      validator = QuestionValidator.new(attributes)
      validator.valid?
      validator
    end
    
    # Validate an option
    def validate_option(attributes)
      validator = OptionValidator.new(attributes)
      validator.valid?
      validator
    end
    
    # Validate a vote
    def validate_vote(attributes)
      validator = VoteValidator.new(attributes)
      validator.valid?
      validator
    end
    
    # Validate a comment
    def validate_comment(attributes)
      validator = CommentValidator.new(attributes)
      validator.valid?
      validator
    end
    
    # Validate multiple entities at once
    def validate_batch(validations)
      results = {}
      
      validations.each do |type, attributes|
        case type
        when :poll
          results[:poll] = validate_poll(attributes)
        when :question
          results[:question] = validate_question(attributes)
        when :option
          results[:option] = validate_option(attributes)
        when :vote
          results[:vote] = validate_vote(attributes)
        when :comment
          results[:comment] = validate_comment(attributes)
        end
      end
      
      results
    end
    
    # Check if all validations pass
    def all_valid?(validations)
      results = validate_batch(validations)
      results.values.all?(&:valid?)
    end
    
    # Get all validation errors
    def all_errors(validations)
      results = validate_batch(validations)
      errors = {}
      
      results.each do |type, validator|
        errors[type] = validator.errors.full_messages unless validator.valid?
      end
      
      errors
    end
  end
end 