class GroupsUser < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  attr_accessible :group_id, :user_id, :admin

  def self.isAdmin?(group, user)
    entry = where("group_id = ? AND user_id = ? AND admin = ?", group, user, true).first
    if entry 
      return true
    else 
      return false
    end
  end

end
