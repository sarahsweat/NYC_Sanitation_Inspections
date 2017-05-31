ENV["ACTIVE_RECORD_ENV"] ||= "development"
require_relative "../config/environment"

cli = CLI.new
cli.search
# cli.sign_up_or_login
