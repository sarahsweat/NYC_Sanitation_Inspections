require 'rest-client'
require 'json'
require 'pry'

# KFC single restaurant example
class API_Comm

  # All Restaurant Results methods
  def self.find_restaurant_by_name name
    rest = RestClient.get('https://data.cityofnewyork.us/resource/9w7m-hzhe.json?dba=' + name)
    all_restaurant_data = JSON.parse(rest)
  end

  # find_restaurant_by_name "BEAST OF BOURBON"

  def self.find_unique_restaurants all_restaurant_data
    all_restaurant_data.uniq {|inspection| inspection["camis"]}
  end

  def self.find_by_boro all_restaurant_data, boro
    hash = {}
    result = all_restaurant_data.select {|inspection| inspection["boro"] == boro.upcase}
    hash["count"] = result.count
    hash["results"] = result
    hash
  end

  def self.find_by_zip all_restaurant_data, zip
    hash = {}
    result = all_restaurant_data.select {|inspection| inspection["zipcode"] == zip.to_s}
    hash["count"] = result.count
    hash["results"] = result
    hash
  end

  # Single Restaurant Unique ID methods
  def self.find_restaurant_data id
    # test with 41011367
    rest = RestClient.get('https://data.cityofnewyork.us/resource/9w7m-hzhe.json?camis=' + id.to_s)
    restaurant_data = JSON.parse(rest)
  end

  def self.select_all_violations restaurant_data
     restaurant_data.map! {|x| x["violation_description"]}
  end

end
