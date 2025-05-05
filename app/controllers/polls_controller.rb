get '/polls' do
  require_login
  
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
    redirect "/polls/#{@poll.id}/questions/new"
  else
    @error = @poll.errors.full_messages.join(", ")
    slim :'polls/new'
  end
end

get '/polls/:id' do
  require_login
  @poll = Poll.find(params[:id])
  
  # Check if user has permission to view the poll
  if @poll.private && !(admin? || organizer? || @poll.organizer_id == current_user.id)
    halt 403, "You don't have permission to view this poll"
  end
  
  @questions = @poll.questions.includes(:options)
  slim :'polls/show'
end

get '/polls/:id/edit' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
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
    redirect "/polls/#{@poll.id}"
  else
    @error = @poll.errors.full_messages.join(", ")
    slim :'polls/edit'
  end
end

delete '/polls/:id' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  @poll.destroy
  redirect '/polls'
end

get '/polls/:id/results' do
  require_login
  @poll = Poll.find(params[:id])
  
  # Check if user has permission to view poll results
  if @poll.private && !(admin? || organizer? || @poll.organizer_id == current_user.id)
    halt 403, "You don't have permission to view this poll's results"
  end
  
  @questions = @poll.questions.includes(:options)
  slim :'polls/results'
end

post '/polls/:id/activate' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  @poll.update(status: 'active')
  redirect "/polls/#{@poll.id}"
end

post '/polls/:id/close' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  @poll.update(status: 'closed')
  redirect "/polls/#{@poll.id}"
end 