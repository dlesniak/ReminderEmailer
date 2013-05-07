module Api
  module V1
    class RemindersController < ApplicationController
      respond_to :json
      before_filter :restrict_access

      def index
        if(params[:start] && params[:end])
          if(@bot_key)
           key = @bot_key
          else
            key = ApiKey.where(:User_id => current_user.id).first
          end
          @reminders = Reminder.in_range(Integer(params[:start]), Integer(params[:end]), key)
          @repeaters = Reminder.find_repeating_reminders(Integer(params[:start]), Integer(params[:end]), key)
        end
        @reminders ||= []
        @repeaters ||= []
        respond_with (@reminders + @repeaters)
      end

      def show
        @reminder = Reminder.find params[:id]
        respond_with @reminder
      end

      def update
        @reminder = Reminder.find params[:id]
        startTime = params[:edit_reminder][:start].to_datetime
        endTime = startTime.dup
        endTime = endTime.change({:hour => 0, :minute => 0, :second => 0})
        endTime += 1.days
        params[:edit_reminder][:start] = startTime.utc.to_s
        params[:edit_reminder][:end] = endTime.utc.to_s
        # this is ugly as hell...
        if @reminder.repeat > 0
          day_diff = params[:edit_reminder][:start].to_datetime.yday - @reminder.start.yday
          @reminder.start += day_diff.days
          @reminder.repeat = params[:edit_reminder][:repeat]
          @reminder.customhtml = params[:edit_reminder][:customhtml]
        else
          @reminder.update_attributes!(params[:edit_reminder])  
        end
        @reminder.save
        respond_with @reminder
      end

      def create
        if !@bot_key.nil? and @bot_key.role == 'event_bot'
          # if an event bot needs to make a reminder, we have to find the user it applies to via the query string
          key = ApiKey.where(:User_id => params[:uid]).first
          params[:reminder][:source] = 'event_bot'
        else
          key = ApiKey.where(:User_id => current_user.id).first
          params[:reminder][:source] = 'user'
        end
        @reminder = Reminder.new(params[:reminder])
        @reminder.api_key_id = key.id
        endDT = @reminder.start.dup
        endDT = endDT.change({:hour => 0, :minute => 0, :second => 0})
        endDT += 1.days
        @reminder.end = endDT
        @reminder.start = @reminder.start.utc
        @reminder.end = @reminder.end.utc
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
              @bot_key = ApiKey.where(access_token: token).first
            else
              respond_with '{"Access Denied"}', :status => :unauthorized, :location => nil
            end
          end
        end
    end
  end
end