Feature: Allow users to create groups

Scenario: Create a new group
  Given I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
  When I have created a group with the name "Engineering Club" and description "A club for engineers."
  And I am on the groups page
  Then I should see a group entry with the name "Engineering Club"
