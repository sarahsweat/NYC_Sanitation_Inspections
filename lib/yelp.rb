require 'pry'
require 'rest-client'
require 'json'
require_relative 'xyz'

@key = ACCESS_TOKEN

def self.search_yelp_by_phone phone_num
  result = RestClient.get("https://api.yelp.com/v3/businesses/search/phone?phone=+1#{phone_num}", {authorization: "Bearer #{@key}"})
  parsed = JSON.parse(result)
  puts parsed["businesses"]
end

search_yelp_by_phone '7187985820'
