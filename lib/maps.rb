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
    output << "Directions from #{jsonData['routes'][0]['start_address']} to #{jsonData['routes'][0]['end_address']}"
    distance = jsonData['routes'][0]['legs'][0]['distance']['text']
    duration = jsonData['routes'][0]['legs'][0]['duration']['text']
    # departure_time = jsonData['routes'][0]['legs'][0]['departure_time']['text']
    departure_time = "jsonData['routes'][0]['legs'][0]['departure_time']['text']"

    output << "Mode: #{mode}\nDistance: #{distance}\nDuration: #{duration}\nDeparture Time: #{departure_time}"
    jsonData["routes"][0]["legs"].each do |e|
      e["steps"].each_with_index{|t,i| output << "[#{i+1}/#{e["steps"].size}] In #{t['distance']['text']}, #{full_sanitizer.sanitize(t['html_instructions'])}"}
    end
    output
  end
end
