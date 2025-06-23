#!/usr/bin/env ruby

# Test file for Poll System Validators
# This demonstrates how to use the validation classes

require_relative 'lib/validators/poll_validator'
require_relative 'lib/validators/question_validator'
require_relative 'lib/validators/option_validator'
require_relative 'lib/validators/vote_validator'
require_relative 'lib/validators/comment_validator'
require_relative 'lib/validators/poll_system_validator'

# Mock User and Poll classes for testing (in real app, these would be ActiveRecord models)
class User
  def self.exists?(id)
    id > 0
  end
end

class Poll
  def self.exists?(id)
    id > 0
  end
  
  def self.find_by(id:)
    return nil unless id > 0
    OpenStruct.new(
      id: id,
      closed?: id == 999, # Mock closed poll
      active?: id != 999,
      private?: id == 888, # Mock private poll
      organizer_id: 1
    )
  end
end

class Question
  def self.exists?(id)
    id > 0
  end
  
  def self.find_by(id:)
    return nil unless id > 0
    OpenStruct.new(
      id: id,
      poll: Poll.find_by(id: 1),
      single_choice?: id == 1,
      multiple_choice?: id == 2
    )
  end
end

class Option
  def self.exists?(id)
    id > 0
  end
  
  def self.find_by(id:)
    return nil unless id > 0
    OpenStruct.new(
      id: id,
      question_id: 1
    )
  end
  
  def self.where(conditions)
    OpenStruct.new(exists?: false)
  end
end

class Vote
  def self.where(conditions)
    OpenStruct.new(exists?: false)
  end
end

puts "=== Poll System Validators Test ===\n\n"

# Test Poll Validator
puts "1. Testing Poll Validator:"
poll_validator = PollValidator.new(
  title: "Test Poll",
  description: "This is a test poll",
  start_date: Date.current + 1.day,
  end_date: Date.current + 7.days,
  status: "active",
  organizer_id: 1,
  private: false
)

if poll_validator.valid?
  puts "✅ Poll validation passed"
else
  puts "❌ Poll validation failed:"
  puts poll_validator.errors.full_messages
end

# Test invalid poll
invalid_poll = PollValidator.new(
  title: "",
  description: "",
  start_date: Date.current - 1.day,
  end_date: Date.current - 2.days,
  status: "invalid_status",
  organizer_id: 0,
  private: nil
)

puts "\nTesting invalid poll:"
if invalid_poll.valid?
  puts "✅ Invalid poll validation passed (should have failed)"
else
  puts "❌ Invalid poll validation failed (expected):"
  puts invalid_poll.errors.full_messages
end

# Test Question Validator
puts "\n2. Testing Question Validator:"
question_validator = QuestionValidator.new(
  poll_id: 1,
  text: "What is your favorite color?",
  question_type: "single_choice"
)

if question_validator.valid?
  puts "✅ Question validation passed"
else
  puts "❌ Question validation failed:"
  puts question_validator.errors.full_messages
end

# Test Option Validator
puts "\n3. Testing Option Validator:"
option_validator = OptionValidator.new(
  question_id: 1,
  text: "Red"
)

if option_validator.valid?
  puts "✅ Option validation passed"
else
  puts "❌ Option validation failed:"
  puts option_validator.errors.full_messages
end

# Test Vote Validator
puts "\n4. Testing Vote Validator:"
vote_validator = VoteValidator.new(
  user_id: 1,
  option_id: 1,
  question_id: 1
)

if vote_validator.valid?
  puts "✅ Vote validation passed"
else
  puts "❌ Vote validation failed:"
  puts vote_validator.errors.full_messages
end

# Test Comment Validator
puts "\n5. Testing Comment Validator:"
comment_validator = CommentValidator.new(
  user_id: 1,
  poll_id: 1,
  content: "Great poll! I really enjoyed participating."
)

if comment_validator.valid?
  puts "✅ Comment validation passed"
else
  puts "❌ Comment validation failed:"
  puts comment_validator.errors.full_messages
end

# Test PollSystemValidator module
puts "\n6. Testing PollSystemValidator Module:"
validations = {
  poll: {
    title: "Module Test Poll",
    description: "Testing the module",
    start_date: Date.current + 1.day,
    end_date: Date.current + 7.days,
    status: "active",
    organizer_id: 1,
    private: false
  },
  question: {
    poll_id: 1,
    text: "Module test question?",
    question_type: "single_choice"
  },
  option: {
    question_id: 1,
    text: "Option A"
  }
}

results = PollSystemValidator.validate_batch(validations)
puts "Batch validation results:"
results.each do |type, validator|
  if validator.valid?
    puts "✅ #{type.to_s.capitalize} validation passed"
  else
    puts "❌ #{type.to_s.capitalize} validation failed:"
    puts validator.errors.full_messages
  end
end

puts "\n=== Test Complete ===" 