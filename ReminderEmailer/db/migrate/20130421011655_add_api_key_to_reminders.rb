class AddApiKeyToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :api_key_id, :integer

  end
end
