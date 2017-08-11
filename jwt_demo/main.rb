require 'sinatra'
require 'json'
require 'active_record'
require_relative 'smokin_token'
require_relative 'user_directory'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql2',
  :encoding => 'utf8',
  :database => 'cloudpercept',
  :username => 'cloudpercept_dev',
  :password => 'Cl0udPercept123',
)

class App
  include SmokinToken
  include UserDirectory
end

APP = App.new

get '/' do
  File.read(File.join("public", "index.html"))
end

# Check token before any access to API
before '/api/*' do
  auth_header = env['HTTP_AUTHORIZATION']
  halt 401 unless auth_header
  auth_values = auth_header.split
  encoded_access_token = auth_values[1] if auth_values.length == 2 && auth_values[0] =~ /Bearer/i
  puts "#{encoded_access_token}"
  halt 401 unless encoded_access_token
  user_info = APP.decode_token(encoded_access_token)
  halt 403 unless user_info
  env['USER_INFO'] = user_info
end

# A bogus API method
get '/api/secret' do
  "The secret is #{rand(10000)}, #{env['USER_INFO']['name']}"
end

# Login
post '/user/login' do
  input = JSON.parse request.body.read
  if input['refresh']
    user_input = APP.decode_token(input['refresh'])
    halt 401 unless user_input
    input = user_input
  end
  user_info = APP.user_directory_lookup(input['user'], input['password'])
  halt 401 unless user_info 
  output = {
    token_type: 'bearer',
    access_token: APP.generate_access_token(user_info),
    refresh_token: APP.generate_refresh_token(input)
  }
  [ 200, { 'Content-Type' => 'application/json' }, output.to_json ]
end

post '/user/register' do
  input = JSON.parse request.body.read
  user_info = APP.user_directory_register(input)
  halt 401 unless user_info 
  output = { user: user_info }
  [ 200, { 'Content-Type' => 'application/json' }, output.to_json ]
end
