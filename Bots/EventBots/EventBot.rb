$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'Plugins'))

begin
  require 'uri'
  require 'net/http'
  require 'json'
  require 'rubygems'
rescue LoadError => e
  puts "Missing dependency #{e.message}. Run a 'gem install' for the package"
  exit 1
end

def class_from_string(str)
  str.split('::').inject(Object) do |mod, class_name|
    mod.const_get(class_name)
  end
end

uri = URI('http://localhost:3000')

Net::HTTP.start('localhost', 3000, 'localhost', 8888) do |http|
  request = Net::HTTP::Get.new('/api/v1/active_events/')
  request['Authorization'] = 'b819b563b60b5d7addd51fe2174260c6'

  response = http.request request # Net::HTTPResponse object

  if response.body == '{"Access Denied"}'
    puts "Don't forget to create a bot and set the access key!"
    exit 1
  end
  data = JSON.parse response.body

  data.each do |event|
    Net::HTTP.start('localhost', 3000, 'localhost', 8888) do |plugin_http|
      plugin_request = Net::HTTP::Get.new('/api/v1/plugin_descriptors/' + event['plugin_id'].to_s + '/')
      plugin_request['Authorization'] = 'b819b563b60b5d7addd51fe2174260c6'

      plugin_response = plugin_http.request plugin_request

      plugin_desc = JSON.parse plugin_response.body

      require plugin_desc['filename']
      className = plugin_desc['filename'].sub('.rb', '').capitalize
      event_class = class_from_string className
      event_object = event_class.new
      event_object.run_handler(event['configuration'], 'b819b563b60b5d7addd51fe2174260c6')
    end
  end
end