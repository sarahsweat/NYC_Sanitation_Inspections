require "pry"

require "./lib/api_communicator"

class CLI

  attr_accessor :user

  def initialize
    puts "Hello and welcome to the best NYC Restaurant Sanitation Evaluation App!"
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

    new_user
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
      puts "------------------------------------------"
      puts "What would you like to do now?"
      puts "1. Search for a restaurant"
      puts "2. See list of saved good restaurants"
      puts "3. See list of saved restaurants to avoid"
      puts "4. Log out"
      puts "Please enter a task number:"
      number = gets.chomp.downcase
      if number[0] == "1"
        # executes search method

      elsif number[0] == "2"
        puts "------------------------------------------"
        puts "---------List of Good Restaurants---------"
        self.user.saved_restaurants.where(good_or_bad: true).each_with_index do |rest, index|
          puts "#{index+1}. #{rest.restaurant.name} - #{rest.restaurant.street}"
        end
      elsif number[0] == "3"
        puts "------------------------------------------"
        puts "-------List of Restaurants to Avoid-------"
        self.user.saved_restaurants.where(good_or_bad: false).each_with_index do |rest, index|
          puts "#{index+1}. #{rest.restaurant.name} - #{rest.restaurant.street}"
        end
      elsif number[0] == "4"
        # Log out, start new cli instance
        puts "Have a good day"
        break
      else
        puts "`````````````````````````````````````````````"
        puts "Task number not recognized! Please try again."
        puts "`````````````````````````````````````````````"
      end
    end


  end

  def search
    puts "------SEARCH FOR A RESTAURANT------"
    name_result = search_name
    # check for nil return value
    # puts "-----Returned #{name_result["count"]} result(s).-----"
    if name_result["count"] == 1
      return_restaurant name_result["results"]
    else
      ask_for_filter name_result
    end
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
      puts "investigate_restaurant method"
    when "2" then
      puts "add_restaurant_to_list method"
    else puts "error"
    end
  end

  def investigate_restaurant
    puts "investigate method"
  end

  def ask_for_filter hash
    # true means available for use
    boro = true
    zipcode = true
    # if one of these is false, do not allow to be re-run
    puts "\n-----Returned #{hash["count"]} result(s).-----"
    puts "Please select from the following filters: "
    puts "1. Borough" unless boro == false
    puts "2. Zipcode" unless zipcode == false

    choice = gets.chomp
    case choice
    when "1" then
      puts "\nPlease enter the borough:"
      b = gets.chomp
      new_results = API_Comm.find_by_boro hash["results"], b
      boro = false
      logic_gate new_results
    when "2" then
      puts "\nPlease enter the zipcode:"
      z = gets.chomp
      new_results = API_Comm.find_by_zip hash["results"], z
      zipcode = false
      logic_gate new_results
    else puts "error"
    end
  end

  def logic_gate hash
    if hash["count"] < 20
      print_addresses hash
    else
      ask_for_filter hash
    end
  end

  def print_addresses hash
    results_ary = API_Comm.find_streets hash
    puts "\nPlease select a store location to continue: "
    results_ary.each_with_index do |rest, index|
      i = index + 1
      puts "#{i}. #{rest["street"]}"
    end
    choice = gets.chomp
    real_choice = choice.to_i - 1
    real_data = results_ary[real_choice]
    binding.pry
  end

  def search_name
    hash = {}
    puts "\nPlease enter a restaurant name: "
    dba = gets.chomp.upcase
    raw_result = API_Comm.find_restaurant_by_name dba
    unique = API_Comm.find_unique_restaurants raw_result
    count = unique.count
    hash["count"] = count
    hash["results"] = unique
    hash
  end
end
