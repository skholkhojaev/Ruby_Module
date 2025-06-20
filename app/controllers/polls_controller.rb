get '/polls' do
  require_login
  log_user_action(Loggers.polls, 'polls_list_accessed')
  
  # Filter polls based on user role
  if admin? || organizer?
    # Admins and organizers can see all polls
    @polls = Poll.all
  else
    # Voters can only see public polls
    @polls = Poll.where(private: false)
  end
  
  slim :'polls/index'
end

get '/polls/new' do
  require_organizer
  log_user_action(Loggers.polls, 'poll_creation_form_accessed')
  slim :'polls/new'
end

post '/polls' do
  require_organizer
  
  # Handle private flag
  private_poll = params[:private] == "1"
  
  @poll = Poll.new(
    title: params[:title],
    description: params[:description],
    start_date: params[:start_date],
    end_date: params[:end_date],
    status: 'draft',
    organizer_id: current_user.id,
    private: private_poll
  )
  
  if @poll.save
    log_user_action(Loggers.polls, 'poll_created', { 
      poll_id: @poll.id, 
      title: @poll.title, 
      private: private_poll,
      organizer: current_user.username 
    })
    redirect "/polls/#{@poll.id}/questions/new"
  else
    log_user_action(Loggers.polls, 'poll_creation_failed', { 
      title: params[:title], 
      errors: @poll.errors.full_messages 
    })
    @error = @poll.errors.full_messages.join(", ")
    slim :'polls/new'
  end
end

get '/polls/:id' do
  require_login
  @poll = Poll.find(params[:id])
  
  # Check if user has permission to view the poll
  if @poll.private && !(admin? || organizer? || @poll.organizer_id == current_user.id)
    log_security_event(Loggers.security, 'unauthorized_poll_access_attempt', { 
      poll_id: params[:id], 
      user: current_user.username 
    })
    halt 403, "You don't have permission to view this poll"
  end
  
  log_user_action(Loggers.polls, 'poll_viewed', { 
    poll_id: params[:id], 
    poll_title: @poll.title 
  })
  @questions = @poll.questions.includes(:options)
  slim :'polls/show'
end

get '/polls/:id/edit' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  log_user_action(Loggers.polls, 'poll_edit_form_accessed', { 
    poll_id: params[:id], 
    poll_title: @poll.title 
  })
  slim :'polls/edit'
end

patch '/polls/:id' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  # Handle private flag
  private_poll = params[:private] == "1"
  
  if @poll.update(
    title: params[:title],
    description: params[:description],
    start_date: params[:start_date],
    end_date: params[:end_date],
    status: params[:status],
    private: private_poll
  )
    log_user_action(Loggers.polls, 'poll_updated', { 
      poll_id: params[:id], 
      poll_title: @poll.title,
      updated_fields: ['title', 'description', 'start_date', 'end_date', 'status', 'private'],
      private_changed: @poll.private_previously_changed?,
      status_changed: @poll.status_previously_changed?
    })
    redirect "/polls/#{@poll.id}"
  else
    log_user_action(Loggers.polls, 'poll_update_failed', { 
      poll_id: params[:id], 
      errors: @poll.errors.full_messages 
    })
    @error = @poll.errors.full_messages.join(", ")
    slim :'polls/edit'
  end
end

delete '/polls/:id' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  poll_title = @poll.title
  @poll.destroy
  log_user_action(Loggers.polls, 'poll_deleted', { 
    poll_id: params[:id], 
    poll_title: poll_title,
    deleted_by: current_user.username 
  })
  redirect '/polls'
end

get '/polls/:id/results' do
  require_login
  @poll = Poll.find(params[:id])
  
  # Check if user has permission to view poll results
  if @poll.private && !(admin? || organizer? || @poll.organizer_id == current_user.id)
    log_security_event(Loggers.security, 'unauthorized_poll_results_access_attempt', { 
      poll_id: params[:id], 
      user: current_user.username 
    })
    halt 403, "You don't have permission to view this poll's results"
  end
  
  log_user_action(Loggers.polls, 'poll_results_viewed', { 
    poll_id: params[:id], 
    poll_title: @poll.title 
  })
  @questions = @poll.questions.includes(:options)
  slim :'polls/results'
end

post '/polls/:id/activate' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  @poll.update(status: 'active')
  log_user_action(Loggers.polls, 'poll_activated', { 
    poll_id: params[:id], 
    poll_title: @poll.title,
    activated_by: current_user.username 
  })
  redirect "/polls/#{@poll.id}"
end

post '/polls/:id/close' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  @poll.update(status: 'closed')
  log_user_action(Loggers.polls, 'poll_closed', { 
    poll_id: params[:id], 
    poll_title: @poll.title,
    closed_by: current_user.username 
  })
  redirect "/polls/#{@poll.id}"
end 