class RemindersController < ApplicationController
  before_filter :authenticate_user!

  def index
    key = ApiKey.where(:User_id => current_user.id).first
    @upcoming_reminders = Reminder.find_upcoming(Time.now(), key)
  end

  def update
    @reminder = Reminder.find params[:id]
    @reminder.update_attributes!(params[:edit_reminder])
  end

  def create
    @reminder = Reminder.create!(params[:reminder])
  end

  def destroy
    @reminder = Reminder.find params[:id]
    @reminder.delete
  end
end
# DANS COMMENT