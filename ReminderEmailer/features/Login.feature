Feature: Allow a user to login

Scenario: Create a new user with an invalid email
  Given I am at the login page
  And I click "Sign up" 
  When I create username "test" with password "password"
  Then I should see the sign up page still

Scenario: Create a new user with an invalid password
  Given I am at the login page
  And I click "Sign up" 
  When I create username "test@test.com" with password "pass"
  Then I should see a flash notice "Password is too short (minimum is 8 characters)"

Scenario: Create a new user
  Given I am at the login page
  And I click "Sign up"
  When I create username "test@test.com" with password "password"
  Then I should see the calendar page

Scenario: An already registered user login
  Given I am at the login page
  Given The user "test@test.com" with password "password" exists
  When I login as username "test@test.com" with password "password"
  Then I should see the calendar page

Scenario: An already registered user enters an incorrect password
  Given I am at the login page
  Given The user "test@test.com" with password "password" exists
  When I login as username "test@test.com" with password "pass"
  Then I should still be at the login page

