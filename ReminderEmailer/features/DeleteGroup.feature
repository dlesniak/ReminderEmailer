Feature: Allow users to delete groups

Scenario:  Delete an existing group

Given I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
And I am logged in as "bob@fakeemail.com" who is an admin of the group "Engineering Club"
When I have deleted the group "Engineering Club"
And I am on the groups page
Then I should not see a group entry with the name "Engineering Club"
