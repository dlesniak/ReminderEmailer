require 'json'

class Weather
  def initialize(user_id)
    @user_id = user_id
  end

  def run_handler(config, access_token)
    json_config = JSON.parse config
    # Have to pass back user_id as query string parameter 'uid', ie url?uid=1
  end
end