class GroupsController < ApplicationController

  def index
    @groups = Group.all
  end

  def show
    id = params[:id]
    @group = Group.find(id)
    @group_users = @group.users
  end

  def new
    # default: render 'new' template
  end

  def create
    @group = Group.create!(params[:group])
    flash[:notice] = "#{@group.name} was successfully created."
    redirect_to groups_path
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    flash[:notice] = "Group '#{@group.name}' deleted."
    redirect_to groups_path
  end

end
