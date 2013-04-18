module Api
  module V1
    class RemindersController < ApplicationController
      respond_to :json     

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
    end
  end
end