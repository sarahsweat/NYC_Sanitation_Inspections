require 'rest-client'
require 'json'
require 'pry'
require './lib/parser'
require './lib/api_communicator'
require './lib/yelp'

module Investigate
  def init id , name_result
    json = API_Comm.find_restaurant_data id
    json.each do |x|
      date_str = x["inspection_date"]
      parsed_date = DateTime.parse(date_str)
      x["new_insp_date"] = parsed_date
    end

    json.sort_by! {|x| x["new_insp_date"]}
    most_recent = json.last
    most_recent_date = most_recent["new_insp_date"].strftime("%m/%d/%Y")

    yelp_results = Yelp.search_yelp_by_phone most_recent["phone"]

    puts "---------------------------------------------".cyan
    puts "           Inspection Details:".cyan
    puts "---------------------------------------------".cyan
    puts "\nName: #{json.first["dba"]}".green
    puts "Street: #{json.first["street"]}".green
    puts "Borough: #{json.first["boro"]}".green
    puts "Current Grade: #{most_recent["grade"]}".green
    puts "Last inspection: #{most_recent_date}".green
    unless yelp_results.empty? || yelp_results["businesses"].empty?
      puts "---------------------------------------------".cyan
      puts "            Details from Yelp".cyan
      puts "---------------------------------------------".cyan
      puts "Price: #{yelp_results.first["price"]}".green
      puts "Open for business? #{yelp_results.first["is_closed"] ? 'Closed' : 'Open'}".green
      puts "Current rating: #{yelp_results.first["rating"]}".green
    end

    puts "\n---------------------------------------------".yellow
    puts "              Menu options: ".yellow
    puts "---------------------------------------------".yellow
    puts "1. Investigate the most recent inspection, or"
    puts "2. Investigate full inspection/violation history"
    puts "3. Return to restaurant menu?"
    puts "Please select a menu item:"

    choice = nil
    while choice.nil?
      choice = gets.chomp
      case choice
      when "1"
        most_recent_inspection most_recent["score"], most_recent["violation_description"]
      when "2"
        search_all_inspections json
      when "3"
        select_and_save_to_list id
      when "menu"
        main_menu
      when "back"
        search_after_input name_result
      else
        choice = nil
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
        puts "Your response was not recognized. Try again.".red
        puts "   Remember to enter menu to start over.".red
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
      end
    end
  end

  def most_recent_inspection score, vio
    puts "\nScore (lower is better): #{score}".cyan
    puts "Inspection notes: #{vio}".cyan
    puts "\n1. Return to inspection menu?"
    choice = nil
    while choice != "1"
      choice = gets.chomp
      init id if choice == "1"
    end
  end

  def search_all_inspections json
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
        search_result = Parser.search_restaurant_violations id, term
        puts "\n1. Return to inspection menu?"
        # puts "2. Search for another term"
        choice = nil
        while choice != "1"
          choice = gets.chomp
          init id if choice == "1"
        end
      when "2"
        violation_ary = []
        json.each do |hash|
          h = []
          h << hash["new_insp_date"].strftime("%m/%d/%Y")
          h << hash["violation_description"]
          # h = {}
          # h["date"] = hash["new_insp_date"].strftime("%m/%d/%Y")
          # h["violation"] = hash["violation_description"]
          violation_ary << h
        end
        violations_table = Terminal::Table.new :rows => violation_ary
        # violation_ary.each {|x| puts "#{x["date"]}: #{x["violation"]}".cyan}
        violations_table.style = {:all_separators => true}
        puts violations_table
        puts "\n1. Return to inspection menu?"
        choice = nil
        while choice != "1"
          choice = gets.chomp
          init id if choice == "1"
        end
      end
    end
  end
end
