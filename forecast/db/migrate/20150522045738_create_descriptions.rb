class CreateDescriptions < ActiveRecord::Migration
  def change
    create_table :descriptions do |t|
      t.float :temp
      t.float :rainfall
      t.float :windSpeed
      t.string :windDirection
      t.time :datetime

      t.timestamps null: false
    end
  end
end
