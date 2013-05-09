class ChangeFormHtmlToText < ActiveRecord::Migration
  def up
    change_column :plugin_descriptors, :form_html, :text, :limit => nil
  end

  def down
    change_column :plugin_descriptors, :form_html, :string
  end
end
