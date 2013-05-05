module Api
  module V1
    class ActiveEventsController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def index
        if user_signed_in?
          @events = ActiveEvent.where(:user_id => current_user.id)
        elsif @bot_key.role == 'event_bot'
          @events = ActiveEvent.all
        elsif @bot_key.role == 'user'
          user = User.find @bot_key.User_id
          @events = ActiveEvent.where(:user_id => user.id)
        end
        respond_with @events
      end

      def create
        plugin = PluginDescriptor.find params[:plugin_id]
        @new_event = ActiveEvent.new(:plugin_id => plugin.id, :configuration => params[:configuration])
        if user_signed_in?
          user  = current_user
        else
          user = User.find @bot_key.User_id
        end
        @new_event.user_id = user.id
        @new_event.title = plugin.title
        @new_event.save

        respond_with(:api, :v1, @new_event)
      end

      def update
        @event = ActiveEvent.find params[:id]
        @event.configuration = params[:configuration]
        @event.save

        respond_with(:api, :v1, @event)
      end

      def destroy
        @event = ActiveEvent.find params[:id]
        @event.delete
        respond_with(:api, :v1, @event, current_user)
      end

      private
        def restrict_access
          # we need to grant access to the api from both bots with api keys and users coming from jquery ajax calls
          token = request.headers['Authorization']
          found = ApiKey.exists?(access_token: token)
          if found
            @bot_key = ApiKey.where(:access_token => token).first
          else
            respond_with '{"Access Denied"}', :status => :unauthorized, :location => nil
          end
        end
    end
  end
end