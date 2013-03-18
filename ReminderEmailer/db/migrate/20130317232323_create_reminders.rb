class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.string :title
      t.boolean :allDay
      t.datetime :start
      t.datetime :end
      t.integer :repeat
      t.references :user

      t.timestamps
    end
    add_index :reminders, :user_id
  end
end
