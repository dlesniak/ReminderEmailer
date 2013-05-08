Feature: Allow a user to create a new reminder

Scenario: Add a new reminder (Declarative)
  Given I am logged in as "TestUser" with password "password"
  When I have added a reminder with title "Testing123" and start datetime "04/04/2013 12:00"
  And I am on the Reminders home page
  Then I should should see a reminder with the title "Testing123" on the calendar
