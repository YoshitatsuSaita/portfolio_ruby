class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('GMAIL_USERNAME', 'noreply@example.com')
  layout 'mailer'
end
