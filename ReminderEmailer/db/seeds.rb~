# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

reminders = [{:title => "TestEvent", :allDay => false, :start => DateTime.new(2013,4,3,12,0), :end => DateTime.new(2013,4,4,12,0), :repeat => 0, :user_id => 1, :created_at => DateTime.now(), :updated_at => DateTime.now(), :customhtml => ""}
            ]

reminders.each do |reminder|
  Reminder.create!(reminder)
end

groups = [{:name => "Intramural Basketball Team", :description => "Group for members of the local intramural basketball team."}, 
          {:name => "Spelunking Club",            :description => "We love exploring caves. If you do too, feel free to join!"},
          {:name => "SELT Group",                 :description => "Making SaaS apps with the MAGIC of Ruby and Rails!"}]

groups.each do |group|
  Group.create!(group)
end

#groups_users = [{:group_id => 0, :user_id => 0}, {:group_id => 2, :user_id => 0},
#                {:group_id => 1, :user_id => 1}, {:group_id =>20, :user_id => 1}]

#groups_users.each do |group_user|
  

users = [{:email => "steve@fakeemail.com", :password => "password", :groups => Group.where("name in ('Intramural Basketball Team', 'SELT Group')")},
         {:email => "joe@fakeemail.com",   :password => "password",   :groups => Group.where("name in ('Spelunking Club', 'SELT Group')")}]

users.each do |user|
  User.create!(user)
end
  
