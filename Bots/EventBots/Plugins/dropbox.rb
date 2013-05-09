require 'json'
require 'dropbox_sdk'

class Dropbox
  def initialize(user_id)
    @user_id = user_id
    @APP_KEY = '1rfd3upzt9dghq9'
    @APP_SECRET = '93jhz2t4496lzmj'
    @ACCESS_TYPE = :dropbox
    
  end

  def run_handler(config, access_token)
    json_config = JSON.parse config
    # Have to pass back user_id as query string parameter 'uid', ie url?uid=1

  end


end