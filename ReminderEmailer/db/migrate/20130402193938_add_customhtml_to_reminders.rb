class AddCustomhtmlToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :customhtml, :string

  end
end
