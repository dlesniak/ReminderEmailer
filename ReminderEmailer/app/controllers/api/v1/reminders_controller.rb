module Api
  module V1
    class RemindersController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def index
        if(params[:start] && params[:end])
          @reminders = Reminder.in_range(Integer(params[:start]), Integer(params[:end]))
        else
          @reminders = Reminder.all
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
        @reminder = Reminder.create!(params[:reminder])
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
            authenticate_or_request_with_http_token do |token, options|
              ApiKey.exists?(access_token: token)
            end
          end
        end
    end
  end
end