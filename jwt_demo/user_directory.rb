##### Mocked up user directory

require 'active_record'

class User < ActiveRecord::Base
end

module UserDirectory

  def user_directory_lookup(user, password)
    user = User.where({ email: user }).first
    return nil unless user
    { email: user.email, api_key: user.api_key, name: user.name }
  end
end
