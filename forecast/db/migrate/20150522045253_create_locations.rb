class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.text :location_id
      t.integer :post_code
      t.float :lat
      t.float :long
      t.datetime :latest_update

      t.timestamps null: false
    end
  end
end
