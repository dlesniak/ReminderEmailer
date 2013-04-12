When(/^I have created a group with the name "(.*?)" and description "(.*?)"$/) do |name, description|
  visit new_group_path
  fill_in 'Group Name', :with => name
  fill_in 'Description', :with => description
  click_button 'Create Group'
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

