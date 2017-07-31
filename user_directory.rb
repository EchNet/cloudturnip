##### Mocked up user directory

module UserDirectory

  USERS = {
    'test' => { password: 'test', info: { name: 'Francis McDonald' } }
  }

  def user_directory_lookup(user, password)
    entry = USERS[user]
    return nil unless entry && entry[:password] == password
    entry[:info]
  end
end
