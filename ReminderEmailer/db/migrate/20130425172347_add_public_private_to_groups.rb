class AddPublicPrivateToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :private, :boolean
  end
end
