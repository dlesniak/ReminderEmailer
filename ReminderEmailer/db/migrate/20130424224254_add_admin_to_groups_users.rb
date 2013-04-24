class AddAdminToGroupsUsers < ActiveRecord::Migration
  def change
    add_column :groups_users, :admin, :boolean
  end
end
