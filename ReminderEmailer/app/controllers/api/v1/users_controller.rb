module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def show
        @user = User.find params[:id]
        respond_with @user
      end

      def key
        key = ApiKey.find params[:id]
        @user = User.find key.User_id
        respond_with @user
      end

      private
        def restrict_access
          token = request.headers['Authorization']
          found = ApiKey.exists?(access_token: token)
          # only mailer bots can access this part of the api
          if found
            key = ApiKey.where(:access_token => token).first
            if not key.role == 'mailer'
              respond_with '{"Access Denied"}', :status => :unauthorized
            end
          else
            respond_with '{"Access Denied"}', :status => :unauthorized
          end
        end
    end
  end
end