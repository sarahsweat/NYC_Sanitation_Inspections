require "pry"

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




end
