require "pry"

require "./lib/api_communicator"

class CLI

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
    puts "-----------SIGNING UP-----------"
    puts "Please enter your desired Username."
    name = gets.chomp.downcase
    new_user = User.new(name)
    puts "Your username is:   #{new_user.username}"
  end

  def login
    puts "-----------LOGGING IN-----------"
    while self.user.nil?
      puts "What is your username?"
      name = gets.chomp.downcase
      @user = User.find_by_name(name)
      if @user.nil?
        puts "User not found! Please try again."
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
    puts "You've found the record for #{name}."
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
    puts "-----Returned #{hash["count"]} result(s).-----"
    puts "Please select from the following filters: "
    puts "1. Borough"
    puts "2. Zipcode"

    choice = gets.chomp
    case choice
    when "1" then
      puts "Please enter the borough:"
      b = gets.chomp
      new_results = API_Comm.find_by_boro hash["results"], b
      boro = false
      logic_gate new_results
    when "2" then
      puts "Please enter the zipcode:"
      z = gets.chomp
      new_results = API_Comm.find_by_zip hash["results"], z
      zipcode = false
      logic_gate new_results
    else puts "error"
    end
  end

  def logic_gate hash
    binding.pry
    if hash["count"] < 20
      print_addresses hash
    else
      ask_for_filter hash
    end
  end

  def print_addresses hash
    
  end

  def search_name
    hash = {}
    puts "Please enter a restaurant name: "
    dba = gets.chomp.upcase
    raw_result = API_Comm.find_restaurant_by_name dba
    unique = API_Comm.find_unique_restaurants raw_result
    count = unique.count
    hash["count"] = count
    hash["results"] = unique
    hash
  end
end
