require 'rest-client'
require 'json'
require 'pry'

# KFC single restaurant example
class API_Comm

  def self.find_restaurant_by_name name
    rest = RestClient.get('https://data.cityofnewyork.us/resource/9w7m-hzhe.json?dba=' + name)
    rest_json = JSON.parse(rest)
  end

  # need to add error handling for these methods

  def self.find_unique_restaurants json_results
    # check data type of camis-num, does this need to be string or num?
    json_results.uniq {|inspection| inspection["camis"]}
  end

  def self.find_by_boro json_results, boro
    json_results.select {|inspection| inspection["boro"] == boro.upcase}
  end

  def self.find_by_zip json_results, zip
    json_results.select {|inspection| inspection["zipcode"] == zip.to_s}
  end

end
