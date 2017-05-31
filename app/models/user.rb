class User < ActiveRecord::Base
   has_many :restaurants

  #  validates_presence_of :username
  #  validates :username, uniqueness: true, presence: true

   def initialize(username)
     @username = username
   end
end
