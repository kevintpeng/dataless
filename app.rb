require 'sinatra/base'
require_relative './lib/notifier'
require_relative './lib/maps'
require_relative './lib/yelp_api'
require 'fuzzystringmatch'
require 'yelp'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Yelp.client.configure do |config|
  config.consumer_key = ENV['YELP_CONSUMER_KEY']
  config.consumer_secret = ENV['YELP_CONSUMER_SECRET']
  config.token = ENV['YELP_TOKEN']
  config.token_secret = ENV['YELP_TOKEN_SECRET']
end

module ServerNotifications
  class App < Sinatra::Base
    set :show_exceptions, false
    set :raise_errors, false
    set :root, File.dirname(__FILE__)

    jarow = FuzzyStringMatch::JaroWinkler.create( :native )

    post '/incoming-sms' do
      directions = ''
      @from = params[:From]
      return Notifier.send_sms(@from,"Welcome to our great transit texting application") if ["hello", "Hello", "hi", "Hi"].include? params[:Body]
      puts "Incoming requesst: #{params[:Body]}"

      if params[:Body].downcase.start_with?('find')
        _, category, location = params[:Body].downcase.match(/(?<=find)(.*?) near (.*)/).to_a
        directions = YelpAPI.connect(category, location)
      else
        origin, dest = params[:Body].split(" to ")
        dest, mode = dest.split(" by ")
        if mode
          modes = ["transit", "bicycling", "walking", "driving", "bus"]
          modeValues = []
          modes.each_with_index do |modeName, index|
            modeValues[index] = jarow.getDistance(mode , modeName)
          end
          mode = modes[modeValues.index(modeValues.max)]
          mode = "transit" if mode == "bus"
        end
        directions = Maps.directions(origin, dest, mode)
      end

      @message = "->"
      while directions.size > 0
        if "#{@message}\n#{directions[0]}".length > 1500
          Notifier.send_sms(@from,@message)
          sleep 5
          @message = "->"
        end

        @message << "\n#{directions.shift}"
      end
      Notifier.send_sms(@from, @message) unless @message.empty?
    end

    get '/' do
      status 200
      body 'Server is Online.'
    end
  end
end
