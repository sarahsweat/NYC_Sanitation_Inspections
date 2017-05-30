require 'rest-client'
require 'json'
require 'pry'

# KFC single restaurant example
class API_Comm
  def find_by_restaurant_name name
    rest = RestClient.get('https://data.cityofnewyork.us/resource/9w7m-hzhe.json?dba=' + name + ')'
    rest_json = JSON.parse(rest)
  end

  # need to add error handling for these methods

  def find_unique_restaurants camis-num, json_results
    # check data type of camis-num, does this need to be string or num?
    json_results.uniq {|inspection| inspection[camis-num.to_s]}
  end

  unique_kfc = all_kfc.uniq {|inspection| inspection["camis"]}
  brooklyn_kfcs = unique_kfc.select {|inspection| inspection["boro"] == "BROOKLYN"}
  kfcs_by_zip = unique_kfc.select {|inspection| inspection["zipcode"] == "10003"}
end
