get '/admin' do
  require_admin
  @user_count = User.count
  @poll_count = Poll.count
  @vote_count = Vote.count
  @recent_activities = Activity.latest.limit(10)
  slim :'admin/dashboard'
end

get '/admin/users' do
  require_admin
  @users = User.all
  slim :'admin/users'
end

get '/admin/users/:id/edit' do
  require_admin
  @user = User.find(params[:id])
  slim :'admin/edit_user'
end

patch '/admin/users/:id' do
  require_admin
  @user = User.find(params[:id])
  
  # Don't update password if blank
  update_params = {
    username: params[:username],
    email: params[:email],
    role: params[:role]
  }
  
  # Only update password if provided
  if params[:password] && !params[:password].strip.empty?
    update_params[:password] = params[:password]
  end
  
  if @user.update(update_params)
    redirect '/admin/users'
  else
    @error = @user.errors.full_messages.join(", ")
    slim :'admin/edit_user'
  end
end

delete '/admin/users/:id' do
  require_admin
  @user = User.find(params[:id])
  
  # Prevent admin from deleting themselves
  if @user.id == current_user.id
    @error = "You cannot delete your own account"
    redirect '/admin/users'
    return
  end
  
  @user.destroy
  redirect '/admin/users'
end

get '/admin/activities' do
  require_admin
  @activities = Activity.latest.paginate(page: params[:page], per_page: 20)
  slim :'admin/activities'
end 