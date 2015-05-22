class AddLocationToDescription < ActiveRecord::Migration
  def change
    add_reference :descriptions, :location, index: true
    add_foreign_key :descriptions, :locations
  end
end
