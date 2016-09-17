require 'rest-client'
require 'rails-html-sanitizer'
require 'json'

module Maps
  def self.directions(origin, destination)
    origin.gsub!(" ", "+").gsub!("_", "+")
    destination.gsub!(" ", "+").gsub!("_", "+")
    full_sanitizer = Rails::HTML::Sanitizer
    output = [];
    # does the thing
    JSON.load(RestClient.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{origin}&destination=#{destination}&key=#{ENV['MAPS_API_KEY']}").body)["routes"][0]["legs"].each {|e| e["steps"].each_with_index
      {|t,i| output << "[#{i}/#{e["steps"].size}] In #{t['distance']['text']}, #{full_sanitizer.sanitize(t['html_instructions'])}"} }
    output
  end
end
