Feature: Allow admins to add and remove users from groups

Scenario: Add a user to a group

Given I have created a user with the email "jeff@fakeemail.com" and password "password" and I am logged in
And I have logged out
And I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
And I am logged in as "bob@fakeemail.com" who is an admin of the group "Engineering Club"
When I add the user "jeff@fakeemail.com" to the group "Engineering Club"
Then I should see a user entry with the email "jeff@fakeemail.com"

Scenario:  Remove a user from a group

Given I have created a user with the email "jeff@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
And I have logged out
And I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have joined the group "Engineering Club"
And I am logged in as "bob@fakeemail.com" who is an admin of the group "Engineering Club"
When I remove the user "jeff@fakeemail.com" from the group "Engineering Club"
Then I should not see a user entry with the email "jeff@fakeemail.com"

