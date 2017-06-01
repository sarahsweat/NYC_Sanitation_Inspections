require "pry"

require "./lib/api_communicator"
require "./lib/support/investigate"
require "terminal-table"
require "colorize"

class CLI
  include Investigate
  attr_accessor :user

  def initialize
    puts "Welcome to the best NYC Restaurant Sanitation Inspection App!"
    @user = nil
  end

  def sign_up_or_login
    su_or_li = false
    while su_or_li == false
      puts "Would you like to sign up or login?"
      name = gets.chomp.downcase.split(" ").join("")
      if name == "login"
        self.login
        su_or_li = true
      elsif name == "signup"
        self.signup
        su_or_li = true
      else
        puts "I did not recognize your response. Please try again."
      end
    end
  end

  def signup
    puts "----------------SIGNING UP----------------"
    puts "Please enter your First Name"
    first_name = gets.chomp.downcase
    puts "Please enter your Last Name"
    last_name = gets.chomp.downcase
    puts "Please enter your desired Username."
    username = gets.chomp.downcase
    new_user = User.find_or_create_by(username: username) do |new_user|
      new_user.first_name = first_name
      new_user.last_name = last_name
    end
    puts "Thanks, #{new_user.first_name.capitalize} #{new_user.last_name.capitalize}."
    puts "Your username is:   #{new_user.username}"
    self.user = new_user
  end

  def login
    puts "----------------LOGGING IN----------------"
    while self.user.nil?
      puts "What is your username?"
      name = gets.chomp.downcase
      self.user = User.find_by(username: name)
      if self.user.nil?
        puts "User not found! Please try again."
      end
    end
    puts "Welcome back, #{self.user.first_name.capitalize} #{self.user.last_name.capitalize}."
    puts "Your username is:   #{self.user.username}"
    self.user
  end

  def main_menu
    task = nil
    while task.nil?
      puts "---------------------------------------------"
      puts "~~~~~         M A I N  M E N U          ~~~~~"
      puts "---------------------------------------------"
      puts "1. Search for a restaurant"
      puts "2. See list of saved good restaurants"
      puts "3. See list of saved restaurants to avoid"
      puts "4. Log out"
      puts "5. Exit app"
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      puts "     You can type menu at any point to"
      puts "  return to this menu, or press back at any "
      puts "      to return to the previous stage."
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      puts "Please enter a task number:"
      number = gets.chomp.downcase
      if number[0] == "1"
        self.search
      elsif number[0] == "2"
        puts "---------------------------------------------"
        puts "----------List of Good Restaurants-----------"
        self.user.saved_restaurants.where(good_or_bad: true).each_with_index do |rest, index|
          puts "#{index+1}. #{rest.restaurant.name} - #{rest.restaurant.street}"
        end
      elsif number[0] == "3"
        puts "---------------------------------------------"
        puts "--------List of Restaurants to Avoid---------"
        self.user.saved_restaurants.where(good_or_bad: false).each_with_index do |rest, index|
          puts "#{index+1}. #{rest.restaurant.name} - #{rest.restaurant.street}"
        end
      elsif number == "4"
        logout
      elsif number == "5"
        break
      else
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts "Task number not recognized! Please try again."
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      end
    end
  end

  def logout
      puts "         Goodbye #{self.user.first_name}! Come back again soon!"
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      self.user = nil
      puts "\nWelcome to the best NYC Restaurant Sanitation Inspection App!"
      sign_up_or_login
  end

  # add while loops to ensure correct input

  def search
    puts "---------------------------------------------"
    puts "----------Search for a Restaurant------------"
    puts "---------------------------------------------"
    name_result = search_name
    #
    # check for nil return value
    #
    if name_result["count"] == 1
      return_restaurant name_result["results"]
    else
      ask_for_filter name_result
    end
  end

  def search_name
    hash = {}
    results = nil
    puts "\nPlease enter a restaurant name: "
    while results == nil
      dba = gets.chomp.upcase
      if dba == "MENU"
        main_menu
      end
      raw_result = API_Comm.find_restaurant_by_name dba
      unique = API_Comm.find_unique_restaurants raw_result
      hash["count"] = unique.count
      hash["results"] = unique
      if unique.count > 0
        results = true
      else
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts "   Restaurant not found! Please try again.   "
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts "\nPlease enter a new restaurant name: "
      end
    end
    hash
  end

  def return_restaurant data
    id = data[0]["camis"]
    name = data[0]["dba"]
    puts "\nYou've found the record for #{name}."
    puts "Please select from the following options: "
    puts "1. Investigate this restaurant"
    puts "2. Add this restaurant to your list"

    selection = gets.chomp
    case selection
    when "1" then
      init id
    when "2" then
      select_and_save_to_list data[0]["camis"]
    else puts "error"
    end
  end

  def select_and_save_to_list id
    # prepare the hash for the save method
    good_or_bad = nil
    hash = API_Comm.create_restaurant_hash id
    # prompt for good or bad list
    while good_or_bad.nil?
      puts "\nWhat would you like to do with this restaurant? "
      puts "1. I would like to visit"
      puts "2. I would like to avoid"
      puts "3. Investigate this restaurant"
      choice = gets.chomp.downcase
      case choice
      when "1" then
        good_or_bad = true
      when "2" then
        good_or_bad = false
      when "3" then
        init id
      when "menu" then
        return main_menu
      else
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts "Your response was not recognized. Try again."
        puts "   Remember to enter menu to start over."
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      end
    end
    # instantiate new restaurant class / association with hash and boolean
    self.user.save_restaurant_to_user(good_or_bad, hash)
    puts "Successfully saved #{hash["name"]}."
    main_menu
  end

  def ask_for_filter hash
    puts "\n----------Returned #{hash["count"]} result(s).----------"
    flag = nil
    while flag.nil?
      puts "\nPlease select from the following filters: "
      puts "1. Borough"
      puts "2. Zipcode"
      choice = gets.chomp.upcase
      case choice
        when "1" then
          search_by_borough hash
        when "2" then
          search_by_zipcode hash
        when "MENU"
          main_menu
        when "back"
          search
        else
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
          puts "  Your input was not recognized, please try again."
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        end
      end
  end

  def search_by_zipcode(hash)
    flag = nil
    while flag.nil?
      puts "\nPlease enter the zipcode or press 1 to go back to filter options"
      z = gets.chomp.downcase
      if z == "1" || z == "back"
        ask_for_filter(hash)
      elsif z == "menu"
        main_menu
      elsif z.to_i.to_s != z || z.length != 5
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts "      Zipcode must be a 5 digit number"
        puts "   Remember to enter menu to start over,  "
        puts "    or 1 to go back to the filter options."
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      else
        flag = true
        new_results = API_Comm.find_by_zip hash["results"], z
        if new_results["count"] == 0
          flag = nil
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
          puts "There are no locations within the specified zipcode."
          puts "                Please try again. "
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        else
          logic_gate new_results
        end
      end
    end
  end

  def search_by_borough(hash)
    flag = nil
    while flag.nil?
      puts "Available Boroughs:"
      puts "1. Manhattan"
      puts "2. Brooklyn"
      puts "3. Queens"
      puts "4. Bronx"
      puts "5. Staten Island"
      puts "6. Go back to filter options"
      puts "7. Go back to search"
      puts "8. Go back to main menu"
      puts "\nPlease select a number:"
      b = gets.chomp.upcase
      flag = false
      case b
        when "1" , "MANHATTAN" then
          boro = "MANHATTAN"
        when "2" , "BROOKLYN" then
          boro = "BROOKLYN"
        when "3" , "QUEENS" then
          boro = "QUEENS"
        when "4" , "BRONX" then
          boro = "BRONX"
        when "5" , "STATEN ISLAND" then
          boro = "STATEN ISLAND"
        when "6" then
           return ask_for_filter(hash)
         when "7" then
           return search
         when "8", "menu" then
           return main_menu
         when "back" then
           ask_for_filter hash
        else
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
          puts "   Sorry, your response was not recognized."
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
          flag = nil
        end
    end
    new_results = API_Comm.find_by_boro hash["results"], boro
    logic_gate new_results
  end

  def logic_gate hash
    if hash["count"] < 2000
      print_addresses hash
    else
      ask_for_filter hash
    end
  end

  def print_addresses hash
    results_ary = API_Comm.find_streets hash
    flag = nil
    while flag.nil?
      puts "\nPlease select a store location by number to continue: "
      rows = []
      results_ary.each_with_index do |rest, index|
        if rest["grade"] == "A"
          rows << ["#{index+1}.", rest["street"], rest["grade"].green]
        elsif rest["grade"] == "B"
          rows << ["#{index+1}.", rest["street"], rest["grade"].yellow]
        elsif rest["grade"] == "C"
          rows << ["#{index+1}.", rest["street"], rest["grade"].red]
        else
          rows << ["#{index+1}.", rest["street"], rest["grade"]]
        end
      end


      table = Terminal::Table.new :title => "Your Search Results".cyan, :headings => ['Number'.cyan, 'Street'.cyan, 'Grade'.cyan], :rows => rows.first(20), :style => {:width => 80}
      puts table

      if rows.count < 20
        flag = true
      end


      while rows.count > 20
        puts "You can type NEXT for more or select a restaurant"
        choice = gets.chomp.downcase
        if choice == "next"
          rows.shift(20)
          table.rows = rows.first(20)
          puts table
        elsif choice.to_i.to_s == choice && choice.to_i <= results_ary.length
          real_choice = choice.to_i - 1
          real_data = results_ary[real_choice]
          select_and_save_to_list real_data["camis"]
          flag = true
        elsif choice == "menu"
          return main_menu
        elsif choice == "back"
          ask_for_filter hash
        else
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
          puts "   Sorry, your response was not recognized."
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        end
      end
    end
  end
end
