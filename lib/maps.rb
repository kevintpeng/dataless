require 'rest-client'
require 'rails-html-sanitizer'
require 'json'

module Maps
  def self.directions(origin, destination, mode="walking")
    origin = origin.gsub(" ", "+").gsub("_", "+")
    destination = destination.gsub(" ", "+").gsub("_", "+")
    full_sanitizer = Rails::Html::FullSanitizer.new
    output = [];
    # does the thing
    url = "https://maps.googleapis.com/maps/api/directions/json?origin=#{origin}&destination=#{destination}&key=#{ENV['MAPS_API_KEY']}&mode=#{mode}"
    jsonData = JSON.load(RestClient.get(url).body)

    output << "Mode: #{mode}\nDistance: #{jsonData['routes'][0]['legs'][0]['distance']['text']}\nDuration: #{jsonData['routes'][0]['legs'][0]['duration']['text']}"      
    jsonData["routes"][0]["legs"].each do |e|
      e["steps"].each_with_index{|t,i| output << "[#{i+1}/#{e["steps"].size}] In #{t['distance']['text']}, #{full_sanitizer.sanitize(t['html_instructions'])}"}
    end
    output
  end
end
