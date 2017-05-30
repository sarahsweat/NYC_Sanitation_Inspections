class CreateBookRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :book_records do |t|
      t.references :book
      t.references :user
      t.boolean :returned
      t.datetime :due_date
    end
  end
end
