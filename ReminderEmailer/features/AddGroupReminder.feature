Feature: Allow admins to add group reminders

Scenario: Add a group reminder

Given I have created a user with the email "jeff@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
And I have logged out
And I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have joined the group "Engineering Club"
And I am logged in as "bob@fakeemail.com" who is an admin of the group "Engineering Club"
When I have added a reminder with title "Reminder" and start datetime "Thu May 9 2013 00:00:00 CDT"
And I have logged out
And I am logged in as "jeff@fakeemail.com" with password "password"
And I am on the Reminders home page
Then I should should see a reminder with the title "Reminder" on the calendar