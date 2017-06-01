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

    json.sort_by! {|x| x["new_insp_date"]}
    most_recent = json.last
    most_recent_date = most_recent["new_insp_date"].strftime("%m/%d/%Y")

    # list
      puts "Name: #{json.first["dba"]}"
      puts "Street: #{json.first["street"]}"
      puts "Borough: #{json.first["boro"]}"
      puts "Current Grade: #{most_recent["grade"]}"
      puts "Last inspection: #{most_recent_date}"
      binding.pry

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
