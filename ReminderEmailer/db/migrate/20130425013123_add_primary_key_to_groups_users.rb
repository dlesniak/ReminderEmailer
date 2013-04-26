class AddPrimaryKeyToGroupsUsers < ActiveRecord::Migration
  def change
    drop_table :groups_users
    create_table :groups_users, do |t|
      t.references :group
      t.references :user
      t.boolean :admin
    end
    add_index :groups_users, [:group_id, :user_id]
    add_index :groups_users, [:user_id, :group_id]
  end
end
