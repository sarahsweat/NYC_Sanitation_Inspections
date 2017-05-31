class Restaurant < ActiveRecord::Base
  has_many :saved_restaurants
  has_many :users, through: :saved_restaurants

  validates_presence_of :camis
  validates :camis, uniqueness: true, presence: true
end
