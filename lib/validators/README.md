# Poll System Validators

This directory contains comprehensive validation classes for the Poll system, including Polls, Questions, Options, Votes, and Comments.

## Overview

The validation system provides:
- **Individual validators** for each entity type
- **Business rule validation** beyond simple field validation
- **Batch validation** capabilities
- **Comprehensive error reporting**

## Validator Classes

### 1. PollValidator
Validates poll creation and updates.

**Fields:**
- `title`: VARCHAR(100) - Required, max 100 characters
- `description`: TEXT - Required
- `start_date`: DATE - Required
- `end_date`: DATE - Required
- `status`: VARCHAR(20) - Required, must be 'draft', 'active', or 'closed'
- `organizer_id`: INTEGER - Required, must reference existing user
- `private`: BOOLEAN - Required, defaults to false

**Business Rules:**
- End date must be after start date
- Active polls cannot have start/end dates in the past
- Organizer must exist

### 2. QuestionValidator
Validates question creation and updates.

**Fields:**
- `poll_id`: INTEGER - Required, must reference existing poll
- `text`: TEXT - Required
- `question_type`: VARCHAR(20) - Required, must be 'single_choice' or 'multiple_choice'

**Business Rules:**
- Poll must exist
- Cannot add questions to closed polls

### 3. OptionValidator
Validates vote option creation and updates.

**Fields:**
- `question_id`: INTEGER - Required, must reference existing question
- `text`: VARCHAR(255) - Required, max 255 characters

**Business Rules:**
- Question must exist
- Cannot add options to questions in closed polls
- Text must be unique within the question

### 4. VoteValidator
Validates vote creation.

**Fields:**
- `user_id`: INTEGER - Required, must reference existing user
- `option_id`: INTEGER - Required, must reference existing option
- `question_id`: INTEGER - Required, must reference existing question

**Business Rules:**
- User, option, and question must exist
- Option must belong to the specified question
- Poll must be active
- For single choice questions, user can only vote once per question
- User cannot vote for the same option twice

### 5. CommentValidator
Validates comment creation.

**Fields:**
- `user_id`: INTEGER - Required, must reference existing user
- `poll_id`: INTEGER - Required, must reference existing poll
- `content`: TEXT - Required, 1-1000 characters

**Business Rules:**
- User and poll must exist
- Cannot comment on private polls unless you are the organizer
- Content cannot be empty or contain only whitespace

## Usage Examples

### Individual Validators

```ruby
# Validate a poll
poll_attributes = {
  title: "My Poll",
  description: "A test poll",
  start_date: Date.current + 1.day,
  end_date: Date.current + 7.days,
  status: "active",
  organizer_id: 1,
  private: false
}

validator = PollValidator.new(poll_attributes)
if validator.valid?
  puts "Poll is valid"
else
  puts "Validation errors: #{validator.errors.full_messages}"
end
```

### Using the PollSystemValidator Module

```ruby
# Validate a single entity
poll_validator = PollSystemValidator.validate_poll(poll_attributes)

# Validate multiple entities at once
validations = {
  poll: poll_attributes,
  question: question_attributes,
  option: option_attributes
}

results = PollSystemValidator.validate_batch(validations)

# Check if all validations pass
if PollSystemValidator.all_valid?(validations)
  puts "All validations passed"
else
  errors = PollSystemValidator.all_errors(validations)
  puts "Validation errors: #{errors}"
end
```

### Integration with Controllers

```ruby
class PollsController < ApplicationController
  def create
    poll_attributes = params.require(:poll).permit(:title, :description, :start_date, :end_date, :status, :private)
    poll_attributes[:organizer_id] = current_user.id
    
    validator = PollSystemValidator.validate_poll(poll_attributes)
    
    if validator.valid?
      @poll = Poll.create(poll_attributes)
      redirect_to @poll, notice: 'Poll created successfully'
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

### Integration with Models

```ruby
class Poll < ActiveRecord::Base
  validate :custom_validation
  
  private
  
  def custom_validation
    validator = PollValidator.new(attributes.symbolize_keys)
    unless validator.valid?
      validator.errors.each do |error|
        errors.add(error.attribute, error.message)
      end
    end
  end
end
```

## Error Handling

All validators return detailed error messages:

```ruby
validator = PollValidator.new(invalid_attributes)
validator.errors.full_messages
# => ["Title can't be blank", "End date must be after start date", "Status is not included in the list"]
```

## Testing

Run the test file to see examples:

```bash
ruby test_validators.rb
```

## Database Schema Requirements

The validators assume the following database schema:

```sql
-- Polls table
CREATE TABLE polls (
  id INTEGER PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'active', 'closed')),
  organizer_id INTEGER NOT NULL REFERENCES users(id),
  private BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Questions table
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  poll_id INTEGER NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  question_type VARCHAR(20) NOT NULL CHECK (question_type IN ('single_choice', 'multiple_choice')),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Options table
CREATE TABLE options (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  text VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Votes table
CREATE TABLE votes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  option_id INTEGER NOT NULL REFERENCES options(id),
  question_id INTEGER NOT NULL REFERENCES questions(id),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  UNIQUE(user_id, option_id)
);

-- Comments table
CREATE TABLE comments (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  poll_id INTEGER NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

## Performance Considerations

- Validators perform database queries to check existence of referenced records
- For high-traffic applications, consider caching validation results
- Batch validation can be more efficient than individual validations
- Consider using database constraints for simple validations

## Contributing

When adding new validators:
1. Follow the existing naming convention
2. Include comprehensive business rule validation
3. Add appropriate tests
4. Update this README with usage examples 