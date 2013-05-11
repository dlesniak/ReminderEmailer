class ChangePluginDescriptionToText < ActiveRecord::Migration
  def up
    change_column :plugin_descriptors, :description, :text, :limit => nil
  end

  def down
    change_column :plugin_descriptors, :description, :string
  end
end