class ActiveEvent < ActiveRecord::Base
  has_one :plugin_descriptor
  has_one :user
end
