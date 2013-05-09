class RemoveJavascriptFromPluginDescriptors < ActiveRecord::Migration
  def up
    remove_column :plugin_descriptors, :javascript
  end

  def down
    add_column :plugin_descriptors, :javascript, :string
  end
end
