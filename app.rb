require 'sinatra/base'
require_relative './lib/notifier'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

module ServerNotifications
  class App < Sinatra::Base
    set :show_exceptions, false
    set :raise_errors, false
    set :root, File.dirname(__FILE__)

    post '/incoming-sms' do
      @message = params[:Body]
      @from = params[:From]
      Notifier.send_sms(@from, @message)
    end

    get '/' do
      status 200
      body ''
    end
  end
end
