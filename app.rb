require 'sinatra/base'
require_relative './lib/notifier'
require_relative './lib/maps'
require 'fuzzystringmatch'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

module ServerNotifications
  class App < Sinatra::Base
    set :show_exceptions, false
    set :raise_errors, false
    set :root, File.dirname(__FILE__)

    jarow = FuzzyStringMatch::JaroWinkler.create( :native )

    post '/incoming-sms' do
      puts "Incoming requesst: #{params[:Body]}"
      origin, dest = params[:Body].split(" to ")
      dest, mode = dest.split(" by ")
      
      if !mode.nil?
        modes = ["transit", "bicycling", "walking", "driving"]
        modeValues = []
        modes.each_with_index do |modeName, index|
          modeValues[index] = jarow.getDistance(mode , modeName)
        end
        mode = modes[modeValues.index(modeValues.max)]
      end

      directions = Maps.directions(origin, dest, mode)

      @from = params[:From]
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
