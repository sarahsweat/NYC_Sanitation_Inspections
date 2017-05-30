ENV["ACTIVE_RECORD_ENV"] ||= "development"
require_relative "../config/environment"

cli = CLI.new

cli.sign_up_or_login

puts "Your username is:   #{cli}"

binding.pry
