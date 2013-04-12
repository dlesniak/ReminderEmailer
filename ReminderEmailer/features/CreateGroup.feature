Feature: Allow users to create groups

Scenario: Create a new group
  When I have created a group with the name "Engineering Club" and description "A club for engineers."
  And I am on the groups page
  Then I should see a group entry with the name "Engineering Club"
