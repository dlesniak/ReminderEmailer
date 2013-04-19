require 'uri'
require 'net/http'

uri = URI('http://localhost:3000/reminders.json')

Net::HTTP.start('localhost', 3000) do |http|
  unixStart = (Time.now - 2.62974e6)
  unixEnd = (Time.now)
  request = Net::HTTP::Get.new 'http://localhost:3000/reminders.json?start=' + (unixStart.to_i.to_s) + '&end=' + (unixEnd.to_i.to_s)

  response = http.request request # Net::HTTPResponse object

  puts response.body
end