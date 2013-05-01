module Api
  module V1
    class PluginDescriptorsController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def show
        @plugin = PluginDescriptor.find params[:id]
        respond_with @plugin
      end

      def create

      end

      private
        def restrict_access
          # we need to grant access to the api from both bots with api keys and users coming from jquery ajax calls
          if user_signed_in?
            true
          else
            token = request.headers['Authorization']
            found = ApiKey.exists?(access_token: token)
            if found
              # RESTful api's should probably not be using sessions...
              @bot_key = ApiKey.where(access_token: token).first
              # if not found
              #   respond_with '{"Access Denied"}', :status => :unauthorized
              # end
            else
              respond_with '{"Access Denied"}', :status => :unauthorized
            end
          end
        end
    end
  end
end