require 'jwt'
require 'time'

module SmokinToken

  # Issue: this has to be agreed upon by the various services.  How do we keep it a secret?
  HMAC_SECRET = 'Cl0udhealth123$'

  HMAC_ALGORITHM = 'HS256'
  ACCESS_DURATION_SECONDS = 30          # 30 seconds
  REFRESH_DURATION_SECONDS = 7*60*60    # 7 hours

  def encode(info)
    JWT.encode info, HMAC_SECRET, HMAC_ALGORITHM
  end

  def decode(str)
    JWT.decode str, HMAC_SECRET, true, { :algorihm => HMAC_ALGORITHM }
  end

  def add_expiry(info, duration_seconds)
    info.merge({ :expiry => (Time.now + duration_seconds).to_s })
  end

  def generate_access_token(user_info)
    encode add_expiry(user_info, ACCESS_DURATION_SECONDS)
  end

  def generate_refresh_token(user_input)
    encode add_expiry(user_input, REFRESH_DURATION_SECONDS)
  end

  def decode_token(encoded_token)
    user_info = decode encoded_token
    user_info = user_info[0]
    begin
      expiry_time = Time.parse(user_info['expiry'])
    rescue
      return nil
    end
puts "expiry time #{expiry_time}"
    return nil if expiry_time < Time.now
puts "expiry time is in the future.  now #{Time.now}"
    return nil if expiry_time > Time.now + REFRESH_DURATION_SECONDS
puts "expiry time is soon"
    user_info
  end
end
