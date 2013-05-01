class AddSourceToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :source, :string

  end
end
