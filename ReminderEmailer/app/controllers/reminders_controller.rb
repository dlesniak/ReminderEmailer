class RemindersController < ApplicationController

  def index
    @reminders = Reminder.all()
    respond_to do |format|
      format.html
      format.json { render :json => @reminders }
    end
  end
end
