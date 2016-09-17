require 'Yelp'

module Yelp
  def self.connect(search_term, location)
    Yelp.client.configure do |config|
      config.consumer_key = ENV['YELP_CONSUMER_KEY']
      config.consumer_secret = ENV['YELP_CONSUMER_SECRET']
      config.token = ENV['YELP_TOKEN']
      config.token_secret = ENV['YELP_TOKEN_SECRET']
    end
    options = {}
    options[term] = search_term if search_term
    client.search(#{location}, options)
    all_options = []
    results.businesses.each { |business| all_options << "#{business.rating}: #{business.name} is at #{business.location.address.join(", ")}"}
    return all_options
  end
end

