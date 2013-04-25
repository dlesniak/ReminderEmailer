require 'uri'
require 'net/http'
require 'json'

uri = URI('http://localhost:3000')

Net::HTTP.start('localhost', 3000) do |http|
  unixStart = (Time.now)
  unixEnd = (Time.now + 60)
  request = Net::HTTP::Get.new('/api/v1/reminders?start=' + (unixStart.to_i.to_s) + '&end=' + (unixEnd.to_i.to_s))
  # request = Net::HTTP::Get.new('/api/v1/users/1/')
  # set the authorization header in the request
  request['Authorization'] = 'edb8ba0599a76b67e8769eb1e7b4b4d7' # a mailer key
  # request['Authorization'] = '3591751c803c7a4c8a39ce043f815623' # a user key

  response = http.request request # Net::HTTPResponse object

  puts response.body

  data = JSON.parse response.body
  puts data
end