require 'yelp'

module YelpAPI
  def self.connect(search_term, location)
    Yelp.client.configure do |config|
      config.consumer_key = ENV['YELP_CONSUMER_KEY']
      config.consumer_secret = ENV['YELP_CONSUMER_SECRET']
      config.token = ENV['YELP_TOKEN']
      config.token_secret = ENV['YELP_TOKEN_SECRET']
    end
    options = {}
    options[:term] = search_term if search_term
    results = client.search(location, options)
    all_results = []
    results.businesses.each { |business| all_results << "#{business.rating}: #{business.name} is at #{business.location.address.join(", ")}"}
    return all_results
  end
end
