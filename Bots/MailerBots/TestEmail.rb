begin
  require 'rubygems'
  require 'tlsmail'
  require 'mail'
rescue LoadError => e
  puts "Missing dependcy #{e.message}. Run a 'gem install' for the package"
  exit 1
end

mail = Mail.new do
  from 'reminderemailer@gmail.com'
  to 'eric.d.brown23@gmail.com'
  subject 'Reminder: Title is coming up soon!'

  html_part do
    content_type 'text/html; charset=UTF-8'
    body %{
      <h3>Title is coming up!</h3>
      <p>You scheduled a reminder for Title at Date. Don't forget about it!</p>
      <div>
        customhtml
      </div>
    }
  end
end
Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', 'reminderemailer@gmail.com', 'reminderemailer23', :login) do |smtp|
  smtp.send_message(mail.to_s, 'reminderemailer@gmail.com', 'eric.d.brown23@gmail.com')
end