Given (/^I am at the login page$/) do
  visit root_path
end

And (/^I click "(.*?)"$/) do |button|
  click_on(button)
end

When (/^I create username "(.*?)" with password "(.*?)"$/) do |username, password|
  fill_in 'user_email', :with=>username
  fill_in 'user_password', :with=>password
  fill_in 'user_password_confirmation', :with=>password
  click_on("Sign up")  
end

Then (/^I should see a flash notice "(.*?)"$/) do |notice|
  assert page.has_content?(notice)
end

Then (/^I should see the sign up page still$/) do
  assert all("hr2").each do |hr|
    hr.has_content?("Sign up")
  end
end

Then (/^I should see the calendar page$/) do
  assert all("hr4").each do |hr|
    hr.has_content?("Upcoming Reminders")
  end
end

Given (/^The user "(.*?)" with password "(.*?)" exists$/) do |username, password|
  User.create(:email => username, :password => password)
end

When (/^I login as username "(.*?)" with password "(.*?)"$/) do |username, password|
  fill_in 'user_email', :with=>username
  fill_in 'user_password', :with=>password
  click_on("Sign in")  
end

Then (/^I should still be at the login page$/) do
  assert all("hr2").each do |hr|
    hr.has_content?("Sign in")
  end
end
