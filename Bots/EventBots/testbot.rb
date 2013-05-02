$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'Plugins'))
require 'test.rb'

def class_from_string(str)
  str.split('::').inject(Object) do |mod, class_name|
    mod.const_get(class_name)
  end
end

event_class = class_from_string 'Test'
event_object = event_class.new
event_object.sadness