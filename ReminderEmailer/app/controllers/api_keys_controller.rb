class ApiKeysController < ApplicationController
  def index
    @keys = ApiKey.all
  end

  def new
    ApiKey.create!(:role => 'mailer')
    redirect_to api_keys_path
  end

  def new_event_bot
    ApiKey.create!(:role => 'event_bot')
    redirect_to api_keys_path
  end
end
