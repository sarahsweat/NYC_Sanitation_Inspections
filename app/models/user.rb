class User < ActiveRecord::Base
   has_many :restaurants

   validates_presence_of :name
   validates :name, uniqueness: true, presence: true



   def initialize(username)
     @username = username
   end


end
