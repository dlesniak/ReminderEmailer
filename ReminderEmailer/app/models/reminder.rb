class Reminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  def self.in_range(start_datetime, end_datetime)
    # Need to filter by user as well probably
    start_datetime = Time.at(start_datetime).to_datetime
    end_datetime = Time.at(end_datetime).to_datetime
    # This could probably be optimized to one query...
    start_reminders = Reminder.find(:all, :conditions => {:start => start_datetime..end_datetime})
    end_reminders = Reminder.find(:all, :conditions => {:end => start_datetime..end_datetime})
    @reminders = (start_reminders + end_reminders).uniq
  end
end
