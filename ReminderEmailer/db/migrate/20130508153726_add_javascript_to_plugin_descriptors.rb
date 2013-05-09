class AddJavascriptToPluginDescriptors < ActiveRecord::Migration
  def change
    add_column :plugin_descriptors, :javascript, :string

  end
end
