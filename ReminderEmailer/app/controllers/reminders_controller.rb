class RemindersController < ApplicationController
  before_filter :authenticate_user!

  def index
    # do nothing
  end

  def update
    @reminder = Reminder.find params[:id]
    @reminder.update_attributes!(params[:edit_reminder])
  end

  def create
    key = ApiKey.where(:User_id => current_user.id).first
    @reminder = Reminder.new(params[:reminder])
    @reminder.api_key_id = key.id
    endDT = @reminder.start.dup
    endDT = endDT.change({:hour => 0, :minute => 0, :second => 0})
    endDT += 1.days
    @reminder.end = endDT
    @reminder.save
  end

  def destroy
    @reminder = Reminder.find params[:id]
    @reminder.delete
  end
end