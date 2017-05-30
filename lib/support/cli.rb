class CLI
  def initialize
    puts "Hello and welcome to the best NYC Restaurant Sanitation Evaluation App!"
  end

  def get_user_info
    while @user.nil?
      puts "What is your name?"
      name = gets.chomp.downcase
      @user = User.find_by_name(name)
      if @user.nil?
        puts "User not found! Please try again."
      end
    end
  end

end
