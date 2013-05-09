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
  def initialize(access_token, uri, proxy_uri)
    @access_token = access_token
    @uri = uri
    @proxy_uri = proxy_uri
  end

  def fetchEvents
    # :use_ssl => uri.scheme == 'https'
    Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
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
    Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |plugin_http|
      plugin_request = Net::HTTP::Get.new('/api/v1/plugin_descriptors/' + event['plugin_id'].to_s + '/')
      plugin_request['Authorization'] = @access_token

      plugin_response = plugin_http.request plugin_request

      plugin_desc = JSON.parse plugin_response.body

      puts "Grabbed a plugin"

      require plugin_desc['filename']
      className = plugin_desc['filename'].sub('.rb', '').capitalize
      puts "About to load plugin: " + className
      event_class = class_from_string className
      event_object = event_class.new()
      reminder = event_object.run_handler(event['configuration'])
      # Have to pass back user_id as query string parameter 'uid', ie url?uid=1
      if reminder
        puts "Set to create a reminder with title: " + reminder[:'reminder[title]']
        attemptReminderCreate(reminder, event)
        if not event['one_off'].nil? and event['one_off']
          removeEvent event
        end
      else
        puts "Nothing to create"
      end
    end
  end

  def attemptReminderCreate(new_reminder, event)
    Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      post_request = Net::HTTP::Post.new('/api/v1/reminders?uid=' + event['user_id'].to_s)
      post_request['Authorization'] = @access_token
      post_request.set_form_data(new_reminder)

      if not reminderExists? new_reminder
        response = http.request post_request
        json_response = JSON.parse response.body
        puts "Created the reminder"
      else
        puts "A reminder already existed there, not creating..."
      end
    end
  end

  def reminderExists?(new_reminder)
    Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      # Check within a 2 minute window of the requested new reminder to see if one has already been created there
      unixStart = new_reminder[:'reminder[start]'] - 60
      unixEnd = new_reminder[:'reminder[start]'] + 60
      request = Net::HTTP::Get.new('/api/v1/reminders?start=' + (unixStart.to_i.to_s) + '&end=' + (unixEnd.to_i.to_s))
      request['Authorization'] = @access_token

      response = http.request request

      json_response = JSON.parse response.body

      json_response.each do |reminder|
        if reminder['title'] == new_reminder[:'reminder[title]']
          return true
        end
      end
      return false
    end
  end

  def removeEvent(event)
    Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Delete.new('/api/v1/active_events/' + event['id'].to_s + '/')
      request['Authorization'] = @access_token

      response = http.request request

      if response.body == '{"Access Denied"}'
        puts "Something is wrong with your apikey"
        exit 1
      else
        puts "Deleted event"
      end
    end
  end

  def class_from_string(str)
    str.split('::').inject(Object) do |mod, class_name|
      mod.const_get(class_name)
    end
  end
end

site_url = 'http://localhost:3000'
proxy_url = 'http://localhost:8888'

ARGV.each do |arg|
  if /\Asite_url=(?<surl>[\w:\/.\-_]*)\z/ =~ arg
    site_url = surl
  elsif /\Aproxy_url=(?<purl>[\w:\/.\-_]*)\z/ =~ arg
    proxy_url = purl
  end
end

uri = URI(site_url)
proxy_uri = URI(proxy_url)

eventBot = EventBot.new('801fdd387f88ea1c07ecc17559c81359', uri, proxy_uri)
eventBot.fetchEvents do |event|
  eventBot.fetchAndRunPlugin event
end