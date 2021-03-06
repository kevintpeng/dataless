module YelpAPI
  def self.connect(search_term, location)
    options = {}
    options[:term] = search_term if search_term
    results = Yelp.client.search(location, options)
    all_results = []
    results.businesses.each { |business| all_results << "#{business.rating}: #{business.name} is at #{business.location.address.join(", ")}"}
    return all_results
  end
end
