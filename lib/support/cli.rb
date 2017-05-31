require "pry"

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
    puts "Thanks, #{new_user.first_name} #{new_user.last_name}."
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




end
