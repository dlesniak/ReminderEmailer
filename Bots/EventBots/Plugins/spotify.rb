require 'uri'
require 'net/http'
require 'json'

class Spotify
  def initialize
    @album_uri = URI('http://ws.spotify.com')
    @artist_uri = URI('http://ws.spotify.com/search/1/artist.json')
  end

  def run_handler(config)    
    Net::HTTP.start(@album_uri.host, @album_uri.port) do |http|
      album = config['album'].gsub(' ', '%20')
      album_request = Net::HTTP::Get.new('/search/1/album.json?q=' + album)

      response = http.request album_request

      puts "Fetched album data"

      json_response = JSON.parse response.body

      json_response['albums'].each do |album|
        if album['name'] == config['album'] and album['artists'][0]['name'] == config['artist']
          reminder = {:'reminder[start]' => (Time.now + 600), :'reminder[title]' => "Your album has been found!", :'reminder[customhtml]' => createhtml(album)}
          return reminder
        end
      end
    end
    return false
  end

  def createhtml(album)
    ref = 'http://open.spotify.com/album/' + album['href'].split(':')[2]
    %{<h2>#{album['name']} is available on Spotify!</h2><p>#{album['name']}, by #{album['artists'][0]['name']} is now available!<p><p>Check it out <a href=#{ref}>here</a></p>
    }
  end
end