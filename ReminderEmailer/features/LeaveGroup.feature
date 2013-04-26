Feature: Allow users to leave groups

Scenario:  Leave an existing group

Given I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
When I leave the group "Engineering Club"
Then I should not see a user entry with the email "bob@fakeemail.com"

