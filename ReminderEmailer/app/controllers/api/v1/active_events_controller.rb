module Api
  module V1
    class ActiveEventsController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def index
        if @bot_key.role == 'eventbot'
          @events = ActiveEvent.all
        else
          @events = ActiveEvent.where(:user_id => current_user.id)
        end
        respond_with @events, :location => nil
      end

      def create
        @new_event = ActiveEvent.create!(:plugin_id => params['plugin_id'], :configuration => params['configuration'])

        respond_with @new_event, :location => nil
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
              @bot_key = ApiKey.where(access_token: token).first
            else
              respond_with '{"Access Denied"}', :status => :unauthorized, :location => nil
            end
          end
        end
    end
  end
end