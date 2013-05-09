Given(/^I have created a user with the email "(.*?)" and password "(.*?)" and I am logged in$/) do |email, password|
  User.create(:email => email, :password => password)

  visit root_path

  fill_in 'user_email', :with => email
  fill_in 'user_password', :with => password
  click_button 'Sign in'
end

When(/^I have created a group with the name "(.*?)" and description "(.*?)"$/) do |name, description|
  visit new_group_path
  fill_in 'group_name', :with => name
  fill_in 'group_description', :with => description
  click_button 'submit'
end

When(/^I am on the groups page$/) do
  visit groups_path
end

Then(/^I should see a group entry with the name "(.*?)"$/) do |name|
  result=false
   all("tr").each do |tr|
     if tr.has_content?(name)
       result = true
       break
     end
   end  
   assert result
end

Given(/^I have added a group with name "(.*?)" and description "(.*?)"$/) do |name, description|
  Group.create(:name => name, :description => description)
end

When(/^I have visited the Details about "(.*?)" page$/) do |name|
  visit groups_path
  click_on "More about #{name}"
end

Then(/^I should see "(.*?)" and "(.*?)"$/) do |text, description|
  if page.has_content?(text) and page.has_content?(description)
    assert true
  else
    assert false 
  end
end

Given(/^I have joined the group "(.*?)"$/) do |group|
  group_id = Group.where("name = ?", group).first.id
  visit group_path(group_id)
  click_button "Join Group"
end

Given(/^I am logged in as "(.*?)" who is an admin of the group "(.*?)"$/) do |user, group|
  userEntry = User.where("email = ?", user).first
  groupEntry = Group.where("name = ?", group).first
  entry = GroupsUser.where("group_id = ? AND user_id = ?", groupEntry.id, userEntry.id).first 
  entry.admin = true
  entry.save
end

Given(/^I am logged in as "(.*?)" who is an admin and owner of the group "(.*?)"$/) do |user, group|
  userEntry = User.where("email = ?", user).first
  groupEntry = Group.where("name = ?", group).first
  groupEntry.owner_id = userEntry.id
  groupEntry.save
  entry = GroupsUser.where("group_id = ? AND user_id = ?", groupEntry.id, userEntry.id).first 
  entry.admin = true
  entry.save
end

When(/^I have deleted the group "(.*?)"$/) do |group|
  group_id = Group.where("name = ?", group).first.id
  visit group_path(group_id)
  click_button "Delete"
end

Then(/^I should not see a group entry with the name "(.*?)"$/) do |name|
  result=true
   all("tr").each do |tr|
     if tr.has_content?(name)
       result = false
       break
     end
   end  
   assert result
end

Then(/^I should see a user entry with the email "(.*?)"$/) do |email|
  result=false
   all("tr").each do |tr|
     if tr.has_content?(email)
       result = true
       break
     end
   end  
   assert result
end

When(/^I leave the group "(.*?)"$/) do |group|
  group_id = Group.where("name = ?", group).first.id
  visit group_path(group_id)
  click_button "Leave Group"
end

Then(/^I should not see a user entry with the email "(.*?)"$/) do |email|
  result=true
   all("tr").each do |tr|
     if tr.has_content?(email)
       result = false
       break
     end
   end  
   assert result
end

Given(/^I have logged out$/) do
  click_on "Sign Out"
end

When(/^I remove the user "(.*?)" from the group "(.*?)"$/) do |user, group|
  group_id = Group.where("name = ?", group).first.id
  visit edit_group_path(group_id)
  
  click_on "Remove " + user
end

Given(/^the privacy level of the group "(.*?)" is set to "(.*?)"$/) do |group, privacy_level|
  group_id = Group.where("name = ?", group).first.id  
  entry = Group.find(group_id)
  if privacy_level == "public"
    entry.private = false
    entry.save
  else
    entry.private = true
    entry.save
  end  
end

When(/^I change the privacy level of the group "(.*?)" to "(.*?)"$/) do |group,
privacy_level|
  group_id = Group.where("name = ?", group).first.id 
  visit group_path(group_id) 
  if privacy_level == "public"
    click_button "Make Group Public"
  else
    click_button "Make Group Private"
  end  
end

When(/^I have added the user "(.*?)" as an admin of the group "(.*?)"$/) do |user, group|
  group_id = Group.where("name = ?", group).first.id 
  visit edit_group_path(group_id)
  #print page.html  
  click_button user
end

Then(/^I should see a button to remove admin status in the entry for "(.*?)" of the group "(.*?)"$/) do |user, group|
  result=false
   all("tr").each do |tr|
     if tr.has_content?(user) && tr.has_button?("Remove Admin")
       result = true
       break
     end
   end  
   assert result
end

When(/^I have removed the user "(.*?)" as an admin of the group "(.*?)"$/) do |user, group|
  group_id = Group.where("name = ?", group).first.id 
  visit edit_group_path(group_id)
  #print page.html  
  click_button user
end

Then(/^I should see a button to add admin status in the entry for "(.*?)" of the group "(.*?)"$/) do |user, group|
  #print page.html
  result=false
   all("tr").each do |tr|
     if tr.has_content?(user) && tr.has_button?("Make Admin")
       result = true
       break
     end
   end  
   assert result
end





