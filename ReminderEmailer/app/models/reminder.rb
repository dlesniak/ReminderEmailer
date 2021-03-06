class Reminder < ActiveRecord::Base
  has_one :api_key
  belongs_to :group
  after_create :sanitize

  def self.in_range(start_datetime, end_datetime, key)
    # handles the reminders happening right now
    start_datetime = Time.at(start_datetime).to_datetime
    end_datetime = Time.at(end_datetime).to_datetime
    # This could probably be optimized to one query...
    start_reminders = Reminder.where(:start => start_datetime..end_datetime)
    # only users have their reminders limited to themselves, bots see everything
    if key.role == 'user' or key.role == 'User'
      # I don't think this is how you should actually query across relationships
      start_reminders = start_reminders.where(:api_key_id => key.id)
    end
    @reminders = start_reminders
  end

  def self.find_repeating_reminders(start_datetime, end_datetime, key)
    start_datetime = Time.at(start_datetime).to_datetime
    end_datetime = Time.at(end_datetime).to_datetime
    @reminders = []
     # collects the reminders which repeat
    repeating_reminders = Reminder.where('repeat > 0')
    if key.role == 'User'
      repeating_reminders = repeating_reminders.where(:api_key_id => key.id)
    end
    repeating_reminders.each do |repeater|
      start_end_diff = repeater.end.yday - repeater.start.yday
      rem_start = repeater.start
      day_diff = start_datetime.yday - repeater.start.yday
      puts day_diff
      if day_diff > 0
        vis_rem = repeater.start + ((Float(day_diff) / Float(repeater.repeat)).round() * repeater.repeat).days
        puts vis_rem
        while vis_rem < end_datetime
          repeated_reminder = repeater.dup
          repeated_reminder.id = repeater.id
          repeated_reminder.start = vis_rem
          endDT = repeated_reminder.start + 1.days
          repeated_reminder.end = endDT.change({:hour => 0, :min => 0, :sec => 0})
          @reminders << repeated_reminder
          vis_rem += repeater.repeat.days
        end
      else
        puts "mid month"
        curr_rep = repeater.start + repeater.repeat.days
        while curr_rep < end_datetime
          repeated_reminder = repeater.dup
          repeated_reminder.id = repeater.id
          repeated_reminder.start = curr_rep
          repeated_reminder.end = repeater.end + repeater.repeat.days
          @reminders << repeated_reminder
          curr_rep += repeater.repeat.days
        end
      end
    end
    @reminders
  end

  private
    def sanitize
      if self.repeat.nil?
        self.repeat = 0
        self.save
      end
    end
end