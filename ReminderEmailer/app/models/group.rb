class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :reminders

  attr_accessible :name, :description, :users
end
