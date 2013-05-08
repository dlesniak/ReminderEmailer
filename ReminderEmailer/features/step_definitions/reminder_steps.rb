Given (/^I am logged in as "(.*?)" with password "(.*?)"$/) do |username, password|
  User.create(:email => username, :password => password)
  visit root_path

  fill_in 'user_email', :with=>username
  fill_in 'user_password', :with=>password
  click_on("Sign in")
end

When (/^I have added a reminder with title "(.*?)" and start datetime "(.*?)"$/) do |title, start|
  click_on("Create a new Reminder")
  fill_in 'reminder_title', :with=>title
  fill_in 'reminder_start', :with=>start
  click_on("Save Reminder")
end

And (/^I am on the reminders home page$/) do
  
end
