class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    id = params[:id]
    @user = current_user
    #@group_users = @group.users
  end

end
