class RemindersController < ApplicationController

  def index
    if(params[:start] && params[:end])
      @reminders = Reminder.in_range(Integer(params[:start]), Integer(params[:end]))
    end
    respond_to do |format|
      format.html
      format.json { render :json => @reminders }
    end
  end

  def update
    @reminder = Reminder.find params[:id]
    @reminder.update_attributes!(params[:edit_reminder])
    render :json => @reminder
  end

  def create
    @reminder = Reminder.create!(params[:reminder])
    render :json => @reminder
  end
end
