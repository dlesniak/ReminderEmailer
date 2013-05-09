Feature: Allow admins to change the privacy level of a group

Scenario:  Make a group private

Given I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
And the privacy level of the group "Engineering Club" is set to "public"
And I am logged in as "bob@fakeemail.com" who is an admin of the group "Engineering Club"
When I change the privacy level of the group "Engineering Club" to "private"
And I have logged out
And I have created a user with the email "jeff@fakeemail.com" and password "password" and I am logged in
And I am on the groups page
Then I should not see a group entry with the name "Engineering Club"

Scenario:  Make a group public

Given I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
And the privacy level of the group "Engineering Club" is set to "private"
And I am logged in as "bob@fakeemail.com" who is an admin of the group "Engineering Club"
When I change the privacy level of the group "Engineering Club" to "public"
And I am on the groups page
Then I should see a group entry with the name "Engineering Club"

