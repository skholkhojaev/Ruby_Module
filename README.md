# Community Poll Hub

A modern platform for polls, surveys, discussions and feedback, developed using Ruby, Sinatra, and SQLite.

## Features

### User Roles

- **Admin**: Monitors system activity, manages users
- **Organizer**: Creates and manages polls
- **Voter**: Participates in polls anonymously

### Core Functionality

- **Poll Management**: Organizers can create polls with single/multiple-choice questions
- **Secure Voting**: Anonymous voting system for registered users
- **Real-time Results**: Visualize poll results with progress bars
- **User Authentication**: Secure login and registration system
- **Activity Logging**: Comprehensive logging of system activities
- **Private Polls**: Organizers can create private polls with restricted visibility
- **Discussions**: Comment on polls and engage in conversations

## Domain Model

The application is built around these core models:

- **User**: Represents users with different roles (admin, organizer, voter)
- **Poll**: A voting event with questions created by organizers
- **Question**: Can be single-choice or multiple-choice
- **Option**: Answer choices for questions
- **Vote**: Anonymous record of user votes
- **Activity**: System logs of important events

## Technical Architecture

- **Framework**: Sinatra (lightweight Ruby web framework)
- **Database**: SQLite with ActiveRecord ORM
- **Authentication**: BCrypt for secure password management
- **Frontend**: Slim templating engine with Bootstrap 5
- **Styling**: Custom CSS for enhanced UI

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Set up the database:
   ```
   rake db:create
   rake db:migrate
   rake db:seed
   ```

4. Start the server:
   ```
   ruby app.rb
   ```

5. Visit `http://localhost:4567` in your browser

## Development Guidelines

### Code Conventions

- Follow Ruby style guidelines
- Use meaningful variable and method names
- Document complex methods

### Database Schema

The database design follows best practices:
- Foreign key constraints for relationships
- Indexes for faster queries
- Appropriate data types for each column

## Testing

Run the test suite with:
```
rspec
```

## License

MIT