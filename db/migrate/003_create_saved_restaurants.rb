class CreateSavedRestaurants < ActiveRecord::Migration[4.2]
  def change
    create_table :saved_restaurants do |t|
      t.references :user
      t.references :restaurant
      t.boolean :good_or_bad
      t.string :notes
    end
  end
end
