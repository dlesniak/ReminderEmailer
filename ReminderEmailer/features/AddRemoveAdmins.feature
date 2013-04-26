Feature: Allow admins to add or remove other admins

Scenario:  Add an admin

Given I have created a user with the email "jeff@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
And I have logged out
And I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have joined the group "Engineering Club"
And I am logged in as "bob@fakeemail.com" who is an admin of the group "Engineering Club"
When I have added the user "jeff@fakeemail.com" as an admin of the group "Engineering Club"
Then I should see a button to remove admin status in the entry for "jeff@fakeemail.com" of the group "Engineering Club"

Scenario:  Remove an admin

Given I have created a user with the email "jeff@fakeemail.com" and password "password" and I am logged in
And I have added a group with name "Engineering Club" and description "A club for engineers."
And I have joined the group "Engineering Club"
And I am logged in as "jeff@fakeemail.com" who is an admin of the group "Engineering Club"
And I have logged out
And I have created a user with the email "bob@fakeemail.com" and password "password" and I am logged in
And I have joined the group "Engineering Club"
And I am logged in as "bob@fakeemail.com" who is an admin of the group "Engineering Club"
When I have removed the user "jeff@fakeemail.com" as an admin of the group "Engineering Club"
Then I should see a button to add admin status in the entry for "jeff@fakeemail.com" of the group "Engineering Club"

