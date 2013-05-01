class CreatePluginDescriptors < ActiveRecord::Migration
  def change
    create_table :plugin_descriptors do |t|
      t.string :title
      t.string :description
      t.string :filename
      t.string :form_html

      t.timestamps
    end
  end
end
