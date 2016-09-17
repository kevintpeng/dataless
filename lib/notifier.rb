require 'yaml'
require 'twilio-ruby'

module Notifier

  def self.send_sms(phone_number, alert_message)
    client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    twilio_number = ENV['TWILIO_NUMBER']
    message = client.account.messages.create(
      from: twilio_number,
      to: phone_number,
      body: alert_message,
    )
    puts "An SMS message was sent to #{message.to[0...-4] + "****"}"
  end
end
