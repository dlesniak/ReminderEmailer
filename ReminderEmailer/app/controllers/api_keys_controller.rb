class ApiKeysController < ApplicationController
  def index
    @keys = ApiKey.all
  end

  def new
    ApiKey.create!(:role => 'mailer')
    redirect_to api_keys_path
  end
end
