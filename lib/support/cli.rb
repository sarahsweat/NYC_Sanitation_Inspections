require "pry"

require "./lib/api_communicator"
require "./lib/support/investigate"
require "terminal-table"
require "colorize"

class CLI
  include Investigate
  attr_accessor :user

  def initialize
    puts "Welcome to the best NYC Restaurant Sanitation Inspection App!".yellow
    @user = nil
    @name_result = nil
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
        puts "I did not recognize your response. Please try again.".red
      end
    end
  end

  def signup
    puts "----------------SIGNING UP----------------".yellow
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
    puts "Thanks, #{new_user.first_name.capitalize} #{new_user.last_name.capitalize}.".green
    puts "Your username is:   #{new_user.username}".green
    self.user = new_user
  end

  def login
    puts "----------------LOGGING IN----------------".yellow
    while self.user.nil?
      puts "What is your username?"
      name = gets.chomp.downcase
      self.user = User.find_by(username: name)
      if self.user.nil?
        puts "User not found! Please try again.".red
      end
    end
    puts "Welcome back, #{self.user.first_name.capitalize} #{self.user.last_name.capitalize}.".green
    puts "Your username is:   #{self.user.username}".green
    self.user
  end

  def main_menu
    task = nil
    while task.nil?
      puts "---------------------------------------------".yellow
      puts "~~~~~         M A I N  M E N U          ~~~~~".yellow
      puts "---------------------------------------------".yellow
      puts "1. Search for a restaurant"
      puts "2. See list of saved good restaurants"
      puts "3. See list of saved restaurants to avoid"
      puts "4. Log out"
      puts "5. Exit app"
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
      puts "     You can type menu at any point to"
      puts "  return to this menu, or press back at any "
      puts "      to return to the previous stage."
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
      puts "Please enter a task number:"
      number = gets.chomp.downcase
      if number[0] == "1"
        self.search
      elsif number[0] == "2"
        puts "---------------------------------------------".yellow
        puts "----------List of Good Restaurants-----------".yellow
        self.user.saved_restaurants.where(good_or_bad: true).each_with_index do |rest, index|
          puts "#{index+1}. #{rest.restaurant.name} - #{rest.restaurant.street}".cyan
        end
      elsif number[0] == "3"
        puts "---------------------------------------------".yellow
        puts "--------List of Restaurants to Avoid---------".yellow
        self.user.saved_restaurants.where(good_or_bad: false).each_with_index do |rest, index|
          puts "#{index+1}. #{rest.restaurant.name} - #{rest.restaurant.street}".cyan
        end
      elsif number == "4"
        logout
      elsif number == "5"
        break
      else
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
        puts "Task number not recognized! Please try again.".red
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
      end
    end
  end

  def logout
      puts "         Goodbye #{self.user.first_name}! Come back again soon!".green
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
      self.user = nil
      puts "\nWelcome to the best NYC Restaurant Sanitation Inspection App!".yellow
      sign_up_or_login
  end

  # add while loops to ensure correct input

  def search
    puts "---------------------------------------------"
    puts "----------Search for a Restaurant------------"
    puts "---------------------------------------------"
    @name_result = search_name
    search_after_input @name_result
  end

  def search_after_input name_result
    if name_result["count"] == 1
      select_and_save_to_list name_result["results"][0]["camis"]
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
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
        puts "   Restaurant not found! Please try again.   ".red
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
        puts "\nPlease enter a new restaurant name: "
      end
    end
    hash
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
        init id, @name_result
      when "menu" then
        return main_menu
      when "back" then
        search_after_input @name_result
      else
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
        puts "Your response was not recognized. Try again.".red
        puts "   Remember to enter menu to start over.".red
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
      end
    end
    # instantiate new restaurant class / association with hash and boolean
    self.user.save_restaurant_to_user(good_or_bad, hash)
    puts "Successfully saved #{hash["name"]}.".green
    main_menu
  end

  def ask_for_filter hash
    puts "\n----------Returned #{hash["count"]} result(s).----------".green
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
        when "BACK"
          search
        else
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
          puts "  Your input was not recognized, please try again.".red
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
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
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
        puts "      Zipcode must be a 5 digit number".red
        puts "   Remember to enter menu to start over,  ".red
        puts "    or 1 to go back to the filter options.".red
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
      else
        flag = true
        new_results = API_Comm.find_by_zip hash["results"], z
        if new_results["count"] == 0
          flag = nil
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
          puts "There are no locations within the specified zipcode.".red
          puts "                Please try again. ".red
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
        else
          logic_gate new_results
        end
      end
    end
  end

  def search_by_borough(hash)
    flag = nil
    while flag.nil?
      puts "Available Boroughs:".yellow
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
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
          puts "   Sorry, your response was not recognized.".red
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
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
      rows = []
      results_ary.each_with_index do |rest, index|
        if rest["grade"] == "A"
          rows << ["#{index+1}.", rest["street"].cyan, rest["grade"].green]
        elsif rest["grade"] == "B"
          rows << ["#{index+1}.", rest["street"].cyan, rest["grade"].yellow]
        elsif rest["grade"] == "C"
          rows << ["#{index+1}.", rest["street"].cyan, rest["grade"].red]
        else
          rows << ["#{index+1}.", rest["street"].cyan, rest["grade"]]
        end

      end


      table = Terminal::Table.new :title => "Your Search Results".cyan, :headings => ['Number'.cyan, 'Street'.cyan, 'Grade'.cyan], :rows => rows.first(20), :style => {:width => 80}
      puts table
      puts "\nPlease select a store location by number to continue: "

      if rows.count < 20
        flag = true
        x = nil
        while x.nil?
          choice = gets.chomp.downcase
          if choice.to_i.to_s == choice && choice.to_i <= results_ary.length
            real_choice = choice.to_i - 1
            real_data = results_ary[real_choice]
            select_and_save_to_list real_data["camis"]
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
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
          puts "   Sorry, your response was not recognized.".red
          puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".yellow
        end
      end
    end
  end
end
