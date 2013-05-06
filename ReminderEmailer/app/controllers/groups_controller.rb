class GroupsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @groups = Group.all
    @user = current_user
    @user_groups = @user.groups

    @has_unjoined_public_groups = false
    @has_joined_public_groups = false
    @has_joined_private_groups = false

    @groups.each do |group|
      if !@user_groups.exists?(group) && !group.private
        @has_unjoined_public_groups = true
      end
    end

    @user_groups.each do |group|
      if group.private
        @has_joined_private_groups = true
      elsif !group.private
        @has_joined_public_groups = true
      end
    end
  end

  def show
    id = params[:id]
    @user = current_user
    @group = Group.find(id)
    @group_private = @group.private
    @group_users = @group.users
  end

  def new
    @user = current_user
    # default: render 'new' template
  end

  def create
    user = current_user
    @group = Group.create!(params[:group].merge(:owner_id => user.id))
    flash[:notice] = "#{@group.name} was successfully created."
    @group.users << user
    @group.groups_users.each do |entry|
      if entry.user_id == user.id
        entry.admin = true
        entry.save
      end
    end
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
    @users = User.all
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
      if(current_user.id = params[:user_id])
        redirect_to group_path(group)
      else
        redirect_to edit_group_path(group)
      end
    end
  end

  def add_user_to
    group = Group.find(params[:id])
    user = User.find(params[:user_id])
    if !group.users.exists?(@user)
      group.users << user
    end
    redirect_to edit_group_path(group)
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

  def add_reminder
    @group = Group.find(params[:id])
    @groups.groups_users.each do |user|
      key = ApiKey.where(:User_id => user.id).first
      @reminder = Reminder.new(params[:reminder])
      @reminder.source = "organization"
      @reminder.api_key_id = key.id
      endDT = @reminder.start.dup
      endDT = endDT.change({:hour => 0, :minute => 0, :second => 0})
      endDT += 1.days
      @reminder.end = endDT
      @reminder.save
    end
  end

end
