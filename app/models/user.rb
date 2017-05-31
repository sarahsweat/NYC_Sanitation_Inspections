class User < ActiveRecord::Base
   has_many :saved_restaurants
   has_many :restaurants, through: :saved_restaurants


   validates_presence_of :username
   validates :username, uniqueness: true, presence: true


   def init_restaurant(restaurant_hash)
     new_restaurant = Restaurant.find_or_create_by(camis: restaurant_hash["camis"]) do |rest|
       rest.name = restaurant_hash["name"]
       rest.street = restaurant_hash["street"]
       rest.boro = restaurant_hash["boro"]
       rest.zip = restaurant_hash["zipcode"]
       rest.phone = restaurant_hash["phone"]
       rest.grade = nil
       rest.score = nil
     end
   end

   def save_restaurant_to_user(good_or_bad,restaurant_hash)
     new_restaurant = init_restaurant(restaurant_hash)
     if self.id.nil?
       puts "User ID cannot be nil"
     else
       SavedRestaurant.find_or_create_by(restaurant_id: new_restaurant.id, user_id: self.id) do |rest|
         rest.good_or_bad = good_or_bad
       end
     end
   end
end
