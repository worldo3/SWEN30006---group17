class ChangeDateFormatInDescription < ActiveRecord::Migration
  def up
  	change_column :descriptions, :datetime, :datetime
  end

  def down
  	change_column :descriptions, :datetime, :time
  end
end
