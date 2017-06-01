require 'rest-client'
require 'json'
require 'pry'

require_relative "parser"
require_relative "api_communicator"

class Investigate

  def self.init id
    json = API_Comm.find_restaurant_data id
    json.each do |x|
      date_str = x["inspection_date"]
      parsed_date = DateTime.parse(date_str)
      x["new_insp_date"] = parsed_date
    end
    binding.pry
    # list
      puts "Name: #{json.first["dba"]}"
      puts "Street: #{json.first["street"]}"
      puts "Borough: #{json.first["boro"]}"
      # current grade
      # most recent inspection date
    # method / selection tree starts here
      # investigate most recent inspection
      # search investigation history
  end

  init 41011367

  def self.recent_inspection

  end

  def self.inspection_history

  end

end
