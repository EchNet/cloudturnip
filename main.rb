require 'sinatra'
require 'json'
require_relative 'smokin_token'
require_relative 'user_directory'

class App
  include SmokinToken
  include UserDirectory
end

APP = App.new

get '/' do
  'This is a JWT demo'
end

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

get '/api/secret' do
  "The secret is #{rand(10000)}, #{env['USER_INFO']['name']}"
end

post '/oath/token' do
  input = JSON.parse request.body.read
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
