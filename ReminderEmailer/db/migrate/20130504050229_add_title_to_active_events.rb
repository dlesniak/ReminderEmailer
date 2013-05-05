class AddTitleToActiveEvents < ActiveRecord::Migration
  def change
    add_column :active_events, :title, :string

  end
end
