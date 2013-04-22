module Api
  module V1
    class RemindersController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def index
        if(params[:start] && params[:end])
          if(session[:bot_key])
            key = session[:bot_key]
          else
            key = ApiKey.where(:User_id => current_user.id).first
          end
          @reminders = Reminder.in_range(Integer(params[:start]), Integer(params[:end]), key)
          session.delete(:bot_key)
        end
        respond_with @reminders
      end

      def show
        @reminder = Reminder.find params[:id]
        respond_with @reminder
      end

      def update
        @reminder = Reminder.find params[:id]
        @reminder.update_attributes!(params[:edit_reminder])
        respond_with @reminder
      end

      def create
        key = ApiKey.where(:User_id => current_user.id).first
        @reminder = Reminder.new(params[:reminder])
        @reminder.api_key_id = key.id
        @reminder.save
        respond_with @reminder
      end

      def destroy
        @reminder = Reminder.find params[:id]
        @reminder.delete
        respond_with @reminder
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
              session[:bot_key] = ApiKey.where(access_token: token).first
              found
            else
              false
            end
          end
        end
    end
  end
end