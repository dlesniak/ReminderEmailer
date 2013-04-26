class GroupsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @groups = Group.all
  end

  def show
    id = params[:id]
    @user = current_user
    @group = Group.find(id)
    @group_users = @group.users
  end

  def new
    @user_id = current_user
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

  def edit
    @group = Group.find params[:id]
    @group_users = @group.users
  end

  def join
    @group = Group.find(params[:id])
    @user = current_user
    
    if !@group.users.exists?(@user)
      @group.users << @user
    end

    redirect_to group_path(@group)
  end

  def delete_user_from
    group = Group.find(params[:id])
    user = User.find(params[:user_id])
    group.users.delete(user)
    page_number = params[:page]

    if page_number.to_i == 0
      redirect_to group_path(group)
    elsif page_number.to_i == 1
      redirect_to edit_group_path(group)
    end
  end

  def add_admin
    @group = Group.find(params[:id])
    @group.groups_users.each do |entry|
      if entry.user_id == params[:user_id].to_i
        entry.admin = true
        entry.save
      end
    end
    redirect_to edit_group_path(@group)
  end

  def remove_admin
    @group = Group.find(params[:id])
    @group.groups_users.each do |entry|
      if entry.user_id == params[:user_id].to_i
        entry.admin = false
        entry.save
      end
    end
    redirect_to edit_group_path(@group)
  end

  def modify_public_private
    @group = Group.find(params[:id])
    @group.private = !@group.private
    @group.save
    redirect_to group_path(@group)
  end

end
