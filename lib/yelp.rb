require 'pry'
require 'rest-client'
require 'json'
require_relative 'xyz'

@@KEY = ACCESS_TOKEN

class Yelp

  def self.search_yelp_by_phone phone_num
    result = RestClient.get("https://api.yelp.com/v3/businesses/search/phone?phone=+1#{phone_num}", {authorization: "Bearer "+ @@KEY})
    parsed = JSON.parse(result)
    parsed["businesses"]
  end

  # search_yelp_by_phone '7187985820'

end
