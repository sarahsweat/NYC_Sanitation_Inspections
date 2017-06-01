require 'rest-client'
require 'json'
require 'pry'

require_relative 'parser'
require_relative 'api_communicator'
require_relative 'yelp'

class Investigate

  attr_accessor :id

  def self.init id
    @id = id

    json = API_Comm.find_restaurant_data id
    json.each do |x|
      date_str = x["inspection_date"]
      parsed_date = DateTime.parse(date_str)
      x["new_insp_date"] = parsed_date
    end

    json.sort_by! {|x| x["new_insp_date"]}
    most_recent = json.last
    most_recent_date = most_recent["new_insp_date"].strftime("%m/%d/%Y")

    puts "\nName: #{json.first["dba"]}"
    puts "Street: #{json.first["street"]}"
    puts "Borough: #{json.first["boro"]}"
    puts "Current Grade: #{most_recent["grade"]}"
    puts "Last inspection: #{most_recent_date}"

    yelp_results = Yelp.search_yelp_by_phone most_recent["phone"]

    # binding.pry
    # Yelp stuff
    puts "Price: #{yelp_results.first["price"]}"
    puts "Open for business? #{yelp_results.first["is_closed"] ? 'Closed' : 'Open'}"
    puts "Current rating: #{yelp_results.first["rating"]}"

    puts "\nPlease select: "
    puts "1. Investigate the most recent inspection, or"
    puts "2. Investigate full inspection/violation history"
    puts "3. Return to restaurant menu?"

    choice = nil
    while choice != "1" || choice != "2" || choice != "3" || choice != "4"
      choice = gets.chomp
      case choice
      when "1"
        most_recent_inspection most_recent["score"], most_recent["violation_description"]
      when "2"
        search_all_inspections json
      when "3"
        puts "Place return to restaurant menu here >>"
      end
    end
  end

  def self.most_recent_inspection score, vio
    puts "\nScore (lower is better): #{score}"
    puts "Inspection notes: #{vio}"
    puts "\n1. Return to inspection menu?"
    choice = nil
    while choice != "1"
      choice = gets.chomp
      init @id if choice == "1"
    end
  end

  def self.search_all_inspections json
    puts "\nPlease select: "
    puts "1. Search for something specific, or"
    puts "2. Investigate entire inspection history"
    choice = nil
    while choice != "1" || choice != "2"
      choice = gets.chomp
      case choice
      when "1"
        puts "\nWhich term would you like to search for?"
        term = gets.chomp
        search_result = Parser.search_restaurant_violations @id, term
        puts "\n1. Return to inspection menu?"
        # puts "2. Search for another term"
        choice = nil
        while choice != "1"
          choice = gets.chomp
          init @id if choice == "1"
        end
      when "2"
        violation_ary = []
        json.each do |hash|
          h = {}
          h["date"] = hash["new_insp_date"].strftime("%m/%d/%Y")
          h["violation"] = hash["violation_description"]
          violation_ary << h
        end
        violation_ary.each {|x| puts "#{x["date"]}: #{x["violation"]}"}
        puts "\n1. Return to inspection menu?"
        choice = nil
        while choice != "1"
          choice = gets.chomp
          init @id if choice == "1"
        end
      end
    end
  end

  init 41011367

end
