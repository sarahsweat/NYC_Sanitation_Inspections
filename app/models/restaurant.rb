class Restaurant < ActiveRecord::Base
  has_many :users
  has_many :inspections

  validates_presence_of :title
  validates :title, uniqueness: true, presence: true
end
