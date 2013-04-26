Feature: Allow users to join groups

Scenario:  Join an existing group

Given I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
When I have joined the group "Engineering Club"
Then I should see a user entry with the email "bob@fakeemail.com"

