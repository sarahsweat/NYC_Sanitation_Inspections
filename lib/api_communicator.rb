require 'rest-client'
require 'json'
require 'pry'

# KFC single restaurant example
class API_Comm
pull_KFC = RestClient.get('https://data.cityofnewyork.us/resource/9w7m-hzhe.json?dba=KFC')
all_kfc = JSON.parse(pull_KFC)

unique_kfc = all_kfc.uniq {|inspection| inspection["camis"]}
brooklyn_kfcs = unique_kfc.select {|inspection| inspection["boro"] == "BROOKLYN"}
kfcs_by_zip = unique_kfc.select {|inspection| inspection["zipcode"] == "10003"}


binding.pry


end
