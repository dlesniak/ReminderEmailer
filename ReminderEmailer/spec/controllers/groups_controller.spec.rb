require 'spec_helper'

describe GroupsController do

  describe 'create a group' do

    it 'should create a new group entry' do
      GroupsController.stub(:create).and_return(mock('Group'))
      post :create, {:id => "1"}
    end

  end

  describe 'delete a group' do

    it 'should destroy the group entry' do
      group = mock(Group, :id => "1", :name => "Engineering Club", :description => "A group for engineers")
      Group.stub!(:find).with("1").and_return(group)
      group.should_receive(:destroy)
      delete :destroy, {:id => "1"}
    end

  end

end
