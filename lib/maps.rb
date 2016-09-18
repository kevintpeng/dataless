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
    leg = jsonData['routes'][0]['legs'][0]
    output << "Directions from #{leg['start_address']} to #{leg['end_address']}"
    distance = leg['distance']['text']
    duration = leg['duration']['text']
    departure_time = leg['departure_time']
    output << "Mode: #{mode}\nDistance: #{distance}" if distance
    output << "Duration: #{duration}" if duration
    output << "Departure Time: #{departure_time['text']}" if departure_time
    jsonData["routes"][0]["legs"].each do |e|
      e["steps"].each_with_index do |t,i|
        instruction = "[#{i+1}/#{e["steps"].size}] #{full_sanitizer.sanitize(t['html_instructions'])}"
        instruction << " (Leaves at #{t['transit_details']['departure_time']['text']}" if t['transit_details']
        instruction << " from the stop #{t['transit_details']['departure_stop']['name']}" if (t['transit_details'] || {})['departure_stop']
        instruction << ")"
        instruction << " for #{t['distance']['text']}."
        output << instruction
      end
    end
    output
  end
end
