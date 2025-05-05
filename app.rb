require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'slim'
require 'bcrypt'

# Load models
Dir["./app/models/*.rb"].each { |file| require file }

# Load controllers
Dir["./app/controllers/*.rb"].each { |file| require file }

# Database configuration
set :database, { adapter: "sqlite3", database: "db/community_poll_hub.sqlite3" }

# Enable sessions for user authentication
enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

# Set application root
set :root, File.dirname(__FILE__)
set :views, Proc.new { File.join(root, "app/views") }
set :public_folder, Proc.new { File.join(root, "public") }

# Root route
get '/' do
  slim :index
end

# Authentication routes
get '/login' do
  slim :login
end

post '/login' do
  user = User.find_by(username: params[:username])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    session[:user_role] = user.role
    redirect '/'
  else
    @error = "Invalid username or password"
    slim :login
  end
end

get '/register' do
  slim :register
end

post '/register' do
  user = User.new(
    username: params[:username],
    email: params[:email],
    role: 'voter', # Default role
    password: params[:password]
  )
  
  if user.save
    session[:user_id] = user.id
    session[:user_role] = user.role
    redirect '/'
  else
    @error = user.errors.full_messages.join(", ")
    slim :register
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

# Helper methods
helpers do
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def admin?
    current_user && current_user.role == 'admin'
  end

  def organizer?
    current_user && current_user.role == 'organizer'
  end

  def voter?
    current_user && current_user.role == 'voter'
  end

  def require_login
    redirect '/login' unless logged_in?
  end

  def require_admin
    redirect '/' unless admin?
  end

  def require_organizer
    redirect '/' unless organizer? || admin?
  end
end 