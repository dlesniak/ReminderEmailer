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
  subject 'Test Email'
  
  text_part do
    body 'This is plain text'
  end

  html_part do
    content_type 'text/html; charset=UTF-8'
    body '<h1>This is HTML</h1>'
  end
end
Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', 'reminderemailer@gmail.com', 'reminderemailer23', :login) do |smtp|
  smtp.send_message(mail.to_s, 'reminderemailer@gmail.com', 'eric.d.brown23@gmail.com')
end