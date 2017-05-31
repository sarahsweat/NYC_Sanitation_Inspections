require 'rest-client'
require 'json'
require 'pry'

# KFC single restaurant example
class API_Comm

  # All Restaurant Results methods
  def self.find_restaurant_by_name name
    rest = RestClient.get('https://data.cityofnewyork.us/resource/9w7m-hzhe.json?dba=' + name.upcase)
    all_restaurant_data = JSON.parse(rest)
  end

  def self.find_unique_restaurants all_restaurant_data
    all_restaurant_data.uniq {|inspection| inspection["camis"]}
  end

  def self.find_by_boro all_restaurant_data, boro
    all_restaurant_data.select {|inspection| inspection["boro"] == boro.upcase}
  end

  def self.find_by_zip all_restaurant_data, zip
    all_restaurant_data.select {|inspection| inspection["zipcode"] == zip.to_s}
  end

  # return street names by alpha methods

  def self.return_street_names all_restaurant_data
    ary = []
    uniq = all_restaurant_data.uniq {|x| x["street"]}
    uniq.each {|x| ary << x["street"]}
    ary.sort!
  end

  # star = self.find_restaurant_by_name "STARBUCKS"
  # return_street_names star

  # Single Restaurant Unique ID methods
  def self.find_restaurant_data id
    # test with 41011367
    rest = RestClient.get('https://data.cityofnewyork.us/resource/9w7m-hzhe.json?camis=' + id.to_s)
    restaurant_data = JSON.parse(rest)
  end

  def self.create_restaurant_hash id
    hash = {}
    data = find_restaurant_data id
    rest = data.first
    hash["camis"] = rest["camis"]
    hash["name"] = rest["dba"]
    hash["street"] = rest["street"]
    hash["boro"] = rest["boro"]
    hash["zip"] = rest["zipcode"]
    hash["phone"] = rest["camis"]
  end

  # create_restaurant_hash 41011367

  def self.select_all_violations restaurant_data
    restaurant_data.map! {|x| x["violation_description"]}
  end

end
