class Group < ActiveRecord::Base
  has_many :groups_users
  has_many :users, :through => :groups_users
  has_many :reminders

  attr_accessible :name, :description, :users, :private
end
