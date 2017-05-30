class User < ActiveRecord::Base
  has_many :restaurants

  # validates_presence_of :name
  # validates :name, uniqueness: true, presence: true


end
