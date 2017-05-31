class CreateRestaurants < ActiveRecord::Migration[4.2]
  def change
    create_table :restaurants do |t|
      t.string :camis
      t.string :name
      t.string :street
      t.string :boro
      t.string :zip
      t.string :phone
      t.string :grade
      t.integer :score
    end
  end
end
