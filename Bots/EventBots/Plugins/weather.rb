require 'uri'
require 'net/http'
require 'json'

class Weather
  def initialize
    @wu_key = '6f1f5a45e9067c88'
    @uri = URI('http://api.wunderground.com')
  end

  def run_handler(config)
    json_config = JSON.parse config
    
    Net::HTTP.start(@uri.host, @uri.port, 'localhost', 8888) do |http|
      weather_request = Net::HTTP::Get.new('/api/' + @wu_key + '/hourly/q/' + json_config['state'] + '/' + json_config['city'] + '.json')

      weather_response = http.request weather_request

      w_json = JSON.parse weather_response.body

      puts "Fetched forecast data"

      w_json['hourly_forecast'].each do |forecast|
        if forecast['FCTTIME']['hour'] == json_config['time']
          if forecast['condition'] == 'Thunderstorm' or forecast['condition'] == 'Rain'
            t = Time.now
            day = t.day
            if json_config['time'].to_i < t.hour 
              day = t.day + 1
            end
            t = Time.local(t.year, t.month, day, json_config['time'].to_i, 0)
            reminder = {:'reminder[title]' => 'Close your windows', :'reminder[start]' => t, :'reminder[customhtml]' => createhtml(forecast)}
            return reminder
          end
        end
      end
    end

    false
  end

  def createhtml(forecast)
    %{<h2>It's going to rain!</h2>
      <p>According to weather underground, the forecast for your scheduled time is #{forecast['condition']}</p>
      <p>You should make sure your windows are closed before you leave the house!</p>}
  end
end