post '/polls/:poll_id/vote' do
  require_login
  @poll = Poll.find(params[:poll_id])
  
  halt 403 unless @poll.active?
  
  # Check if votes param exists
  if !params[:votes] || params[:votes].empty?
    @error = "Please select at least one option to vote"
    redirect "/polls/#{@poll.id}"
    return
  end
  
  # Process vote for each question
  params[:votes].each do |question_id, option_data|
    question = Question.find(question_id)
    
    if question.single_choice?
      # Single choice question
      option_id = option_data.to_i
      next if option_id.zero?
      
      # Delete any existing votes by this user for this question
      Vote.where(user_id: current_user.id, question_id: question_id).destroy_all
      
      # Create new vote
      Vote.create(
        user_id: current_user.id,
        option_id: option_id,
        question_id: question_id
      )
    else
      # Multiple choice question
      # Check if at least one option is selected
      selected_options = option_data.select { |_, is_selected| is_selected == "1" }
      next if selected_options.empty?
      
      option_data.each do |option_id, is_selected|
        next unless is_selected == "1"
        
        # Check if vote already exists
        existing_vote = Vote.find_by(
          user_id: current_user.id,
          option_id: option_id,
          question_id: question_id
        )
        
        unless existing_vote
          Vote.create(
            user_id: current_user.id,
            option_id: option_id,
            question_id: question_id
          )
        end
      end
    end
  end
  
  redirect "/polls/#{@poll.id}/results"
end 