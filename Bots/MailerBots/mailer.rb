require 'uri'
require 'net/http'

uri = URI('http://localhost:3000')

Net::HTTP.start('localhost', 3000, 'localhost', 8888) do |http|
  unixStart = (Time.now - 2.62974e6)
  unixEnd = (Time.now)
  request = Net::HTTP::Get.new('/api/v1/reminders?start=' + (unixStart.to_i.to_s) + '&end=' + (unixEnd.to_i.to_s))
  # set the authorization header in the request
  # request['Authorization'] = 'Token token="6d293182cebb697d81c3ecc6dec72b8c"'
  request['Authorization'] = '6d293182cebb697d81c3ecc6dec72b8c'

  response = http.request request # Net::HTTPResponse object

  puts response.body
end