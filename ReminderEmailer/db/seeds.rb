# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

reminders = [{:title => "1", :allDay => false, :start => DateTime.new(2013,4,3,12,0), :end => DateTime.new(2013,4,4,12,0), :repeat => 0, :user_id => 1, :created_at => DateTime.now(), :updated_at => DateTime.now(), :customhtml => ""}
            ]

reminders.each do |reminder|
  Reminder.create!(reminder)
end