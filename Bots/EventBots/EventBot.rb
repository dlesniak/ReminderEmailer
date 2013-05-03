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

class EventBot
  def initialize(access_token, site_url, site_port, proxy_url, proxy_port)
    @access_token = access_token
    @site_url = site_url
    @site_port = site_port
    @proxy_url = proxy_url
    @proxy_port = proxy_port
  end

  def fetchEvents
    Net::HTTP.start(@site_url, @site_port, @proxy_url, @proxy_port) do |http|
      request = Net::HTTP::Get.new('/api/v1/active_events/')
      request['Authorization'] = @access_token

      response = http.request request # Net::HTTPResponse object

      if response.body == '{"Access Denied"}'
        puts "Don't forget to create a bot and set the access key!"
        exit 1
      end
      data = JSON.parse response.body

      puts "Got events, grabbing matching plugins"
      data.each do |event|
        yield event
      end    
    end
  end

  def fetchAndRunPlugin(event)
    Net::HTTP.start(@site_url, @site_port, @proxy_url, @proxy_port) do |plugin_http|
      plugin_request = Net::HTTP::Get.new('/api/v1/plugin_descriptors/' + event['plugin_id'].to_s + '/')
      plugin_request['Authorization'] = @access_token

      plugin_response = plugin_http.request plugin_request

      plugin_desc = JSON.parse plugin_response.body

      puts "Grabbed a plugin"

      require plugin_desc['filename']
      className = plugin_desc['filename'].sub('.rb', '').capitalize
      event_class = class_from_string className
      event_object = event_class.new
      event_object.run_handler(event['configuration'], @access_token)
    end
  end

  def class_from_string(str)
    str.split('::').inject(Object) do |mod, class_name|
      mod.const_get(class_name)
    end
  end
end

site_url = 'localhost'
site_port = 3000
proxy_url = 'localhost'
proxy_port = 8888

ARGV.each do |arg|
  if /\Asite_url=(?<surl>[\w:\/.\-_]*)\z/ =~ arg
    site_url = surl
  elsif /\Asite_port=(?<sport>[\d:\/.\-_]*)\z/ =~ arg
    site_port = sport.to_i
  elsif /\Aproxy_url=(?<purl>[\w:\/.\-_]*)\z/ =~ arg
    proxy_url = purl
  elsif /\Aproxy_port=(?<pport>[\d:\/.\-_]*)\z/ =~ arg
    proxy_port = pport.to_i
  end
end

eventBot = EventBot.new('b819b563b60b5d7addd51fe2174260c6', site_url, site_port, proxy_url, proxy_port)
eventBot.fetchEvents do |event|
  eventBot.fetchAndRunPlugin(event)
end