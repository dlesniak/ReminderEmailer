begin
  require 'uri'
  require 'net/http'
  require 'json'
  require 'rubygems'
rescue LoadError => e
  puts "Missing dependency #{e.message}. Run a 'gem install' for the package"
  exit 1
end

uri = URI('http://localhost:3000')

Net::HTTP.start('localhost', 3000, 'localhost', 8888) do |http|
  request = Net::HTTP::Get.new('/api/v1/active_events/')
  request['Authorization'] = 'edb8ba0599a76b67e8769eb1e7b4b4d7'

end

$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'lib' ) )