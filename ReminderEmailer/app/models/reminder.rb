class Reminder < ActiveRecord::Base
  has_one :api_key
  belongs_to :group

  def self.in_range(start_datetime, end_datetime, key)
    start_datetime = Time.at(start_datetime).to_datetime
    end_datetime = Time.at(end_datetime).to_datetime
    # This could probably be optimized to one query...
    start_reminders = Reminder.where(:start => start_datetime..end_datetime)
    end_reminders = Reminder.where(:end => start_datetime..end_datetime)
    # only users have their reminders limited to themselves, bots see everything
    if key.role == 'User'
      # I don't think this is how you should actually query across relationships
      start_reminders = start_reminders.where(:api_key_id => key.id)
      end_reminders = end_reminders.where(:api_key_id => key.id)
    end
    @reminders = (start_reminders + end_reminders).uniq
  end
end
