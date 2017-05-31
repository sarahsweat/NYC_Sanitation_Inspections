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
    count = name_result["count"]
    while count > 20
    if count == 1
      # return restaurant
    else
      # ask for next filter
    end
    # print_addresses
  end

  def return_restaurant

  end

  def ask_for_filter

  end

  def print_addresses

  end

  def search_name
    hash = {}
    puts "Please enter a restaurant name: "
    dba = "gets.chomp.upcase"
    raw_result = API_Comm.find_restaurant_by_name dba
    unique = API_Comm.find_unique_restaurants raw_result
    count = unique.count
    hash["count"] = count
    hash["results"] = unique
    hash
  end
end
