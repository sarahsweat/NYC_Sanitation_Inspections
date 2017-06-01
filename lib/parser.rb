require 'json'
require 'pry'

require_relative 'api_communicator'

class Parser

  hot_list = {
    pests: ["mouse", "mice", "roach", "fly", "flies"],
    handling: ["cross-contamination", "not hot", "not warm", "not cold", "not cool", "unsanitary equipment"],
    facility: ["worker hygiene", "hand-washing", "food storage", "food surfaces"]
  }

  def self.search_restaurant_violations id, search_term
    result = nil
    regex = Regexp.new search_term
    data = API_Comm.find_restaurant_data id
    violation_data = API_Comm.select_all_violations data
    joined = violation_data.join(" ")
    if regex.match(joined)
      puts "Search for " + search_term + " returned " + true.to_s
    else
      puts "Search for " + search_term + " returned " + false.to_s
    end
  end

end
