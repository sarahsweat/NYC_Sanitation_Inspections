ENV["ACTIVE_RECORD_ENV"] ||= "development"
require_relative "../config/environment"

escape_app = false


  cli = CLI.new
  cli.sign_up_or_login
  cli.main_menu


puts "Goodbye"

#binding.pry
