class WeathersController < ApplicationController

  def index
  end

  def location
  	@locations = Location.all
  	time = Time.now
  	@date = time.strftime("%d-%m-%y")
  end

  def data
  end

  def prediction
  end
end
