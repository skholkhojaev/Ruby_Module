# Get comments for a poll
get '/polls/:poll_id/comments' do
  @poll = Poll.find(params[:poll_id])
  @comments = @poll.comments.latest.includes(:user)
  slim :'comments/index'
end

# Create a new comment
post '/polls/:poll_id/comments' do
  require_login
  @poll = Poll.find(params[:poll_id])
  
  # Validate comment content
  if params[:content].strip.empty?
    @error = "Comment cannot be empty"
    redirect "/polls/#{@poll.id}"
  end
  
  @comment = Comment.new(
    poll_id: @poll.id,
    user_id: current_user.id,
    content: params[:content]
  )
  
  if @comment.save
    redirect "/polls/#{@poll.id}#comments"
  else
    @error = @comment.errors.full_messages.join(", ")
    redirect "/polls/#{@poll.id}"
  end
end

# Delete a comment
delete '/comments/:id' do
  require_login
  @comment = Comment.find(params[:id])
  
  # Only comment owner or admin can delete
  halt 403 unless current_user.id == @comment.user_id || admin?
  
  poll_id = @comment.poll_id
  @comment.destroy
  
  redirect "/polls/#{poll_id}#comments"
end 