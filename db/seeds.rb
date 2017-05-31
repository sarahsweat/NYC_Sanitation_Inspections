require "pry"

user1 = User.create(username: "abc123")
user2 = User.create(username: "def456")
user3 = User.create(username: "candygirl_937")
user4 = User.create(username: "badchick_999")


user1.first_name = "Sarah"
user2.first_name = "Jason"
user3.first_name = "Jared"
user4.first_name = "Yomi"

user1.last_name = "Sweat"
user2.last_name = "Sears"
user3.last_name = "Johnson"
user4.last_name = "Dude"

user1.save
user2.save
user3.save
user4.save

restaurant_hash1 = {"camis" => "45682",
                    "name" => "KFC",
                    "street" =>"11 broadway",
                    "boro" => "manhattan",
                    "zip" => "11001",
                    "phone" => "5555555555"
                    }
restaurant_hash2 = {"camis" => "12345",
                    "name" => "KFC",
                    "street" =>"18 broadway",
                    "boro" => "manhattan",
                    "zip" => "11004",
                    "phone" => "6666666666"
                    }
restaurant_hash3 = {"camis" => "87655",
                    "name" => "Subway",
                    "street" =>"789 broadway",
                    "boro" => "manhattan",
                    "zip" => "00116",
                    "phone" => "3456781122"
                    }
restaurant_hash4 = {"camis" => "01224",
                    "name" => "McDonalds",
                    "street" =>"7892 broadway",
                    "boro" => "manhattan",
                    "zip" => "09862",
                    "phone" => "9876547733"
                    }

rest1 = user1.save_restaurant_to_user(true, restaurant_hash1)
rest2 = user2.save_restaurant_to_user(false, restaurant_hash2)
rest3 = user3.save_restaurant_to_user(true, restaurant_hash3)
rest4 = user4.save_restaurant_to_user(false, restaurant_hash4)
