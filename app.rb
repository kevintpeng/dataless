require 'sinatra/base'
require_relative './lib/notifier'
require_relative './lib/maps'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

module ServerNotifications
  class App < Sinatra::Base
    set :show_exceptions, false
    set :raise_errors, false
    set :root, File.dirname(__FILE__)

    post '/incoming-sms' do
      origin, dest = params[:Body].split(" to ")
      directions = Maps.directions(origin, dest)
      @from = params[:From]
      @message = "\n"
      while directions.size > 0
        if "#{@message}\n#{directions[0]}".length > 1500
          Notifier.send_sms(@from,@message)
          sleep 5
          @message = "\n"
        end
        
        @message << "\n#{directions.shift}"
      end
      Notifier.send_sms(@from, @message) unless @message.empty?
    end

    get '/' do
      status 200
      body ''
    end
  end
end
