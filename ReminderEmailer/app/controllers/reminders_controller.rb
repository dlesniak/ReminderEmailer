class RemindersController < ApplicationController

  def index
    # Essentially do nothing, since the real data is coming from the api
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