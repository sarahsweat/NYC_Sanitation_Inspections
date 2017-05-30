ENV["ACTIVE_RECORD_ENV"] ||= "development"
require_relative "../config/environment"

cli = CLI.new

cli.get_user_info

binding.pry
