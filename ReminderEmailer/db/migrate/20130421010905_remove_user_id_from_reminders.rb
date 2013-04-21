class RemoveUserIdFromReminders < ActiveRecord::Migration
  def up
    remove_column :reminders, :user_id
      end

  def down
    add_column :reminders, :user_id, :integer
  end
end
