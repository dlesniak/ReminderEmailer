class CreateActiveEvents < ActiveRecord::Migration
  def change
    create_table :active_events do |t|
      t.integer :plugin_id
      t.integer :user_id
      t.string :configuration

      t.timestamps
    end
  end
end
