module Api
  module V1
    class PluginDescriptorsController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def show
        @plugin = PluginDescriptor.find params[:id]
        respond_with @plugin, :location => nil
      end

      private
        def restrict_access
          # we need to grant access to the api from both bots with api keys and users coming from jquery ajax calls
          token = request.headers['Authorization']
          found = ApiKey.exists?(access_token: token)
          if found
            @bot_key = ApiKey.where(access_token: token).first
          else
            respond_with '{"Access Denied"}', :status => :unauthorized, :location => nil
          end
        end
    end
  end
end