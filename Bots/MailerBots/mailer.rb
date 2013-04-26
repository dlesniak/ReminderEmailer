begin
  require 'uri'
  require 'net/http'
  require 'json'
  require 'rubygems'
  require 'tlsmail'
  require 'mail'
rescue LoadError => e
  puts "Missing dependency #{e.message}. Run a 'gem install' for the package"
  exit 1
end

uri = URI('http://localhost:3000')

Net::HTTP.start('localhost', 3000, 'localhost', 8888) do |http|
  unixStart = Time.now
  unixEnd = Time.now + 432000
  request = Net::HTTP::Get.new('/api/v1/reminders?start=' + (unixStart.to_i.to_s) + '&end=' + (unixEnd.to_i.to_s))
  # request = Net::HTTP::Get.new('/api/v1/users/1/')
  # set the authorization header in the request
  # request['Authorization'] = '441494c88d94b976ef7a25db7982c159' # a mailer key, Eric Desktop key
  request['Authorization'] = 'edb8ba0599a76b67e8769eb1e7b4b4d7' # a mailer key, Eric Laptop key
  # request['Authorization'] = '3591751c803c7a4c8a39ce043f815623' # a user key

  response = http.request request # Net::HTTPResponse object

  if response.body == '{"Access Denied"}'
    puts "Don't forget to create a bot and set the access key!"
    exit 1
  end
  data = JSON.parse response.body

  puts "Got Reminders"
  data.each do |reminder|
    key_id = reminder['api_key_id']
    Net::HTTP.start('localhost', 3000, 'localhost', 8888) do |user_http|
      user_request = Net::HTTP::Get.new('/api/v1/users/key/' + key_id.to_s + '/')
      user_request['Authorization'] = 'edb8ba0599a76b67e8769eb1e7b4b4d7'

      user_response = user_http.request user_request

      user = JSON.parse user_response.body

      datetime_string = DateTime.strptime(reminder['start'], '%Y-%m-%dT%H:%M:%S%z').strftime('%B %e %Y, %l:%M %p')

      puts "Sending email"
      mail = Mail.new do
        from 'reminderemailer@gmail.com'
        to user['email']
        subject 'Reminder: ' + reminder['title'] + ' is coming up soon!'

        html_part do
          content_type 'text/html; charset=UTF-8'
          body %{
            <h3>#{reminder['title']} is coming up!</h3>
            <p>You scheduled a reminder for #{reminder['title']} at #{datetime_string}. Don't forget about it!</p>
            <div>
              #{reminder['customhtml']}
            </div>
          }
        end
      end
      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', 'reminderemailer@gmail.com', 'reminderemailer23', :login) do |smtp|
        smtp.send_message(mail.to_s, 'reminderemailer@gmail.com', 'eric.d.brown23@gmail.com')
      end
    end
  end
end