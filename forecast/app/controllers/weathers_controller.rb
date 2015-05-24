class WeathersController < ApplicationController

  def index
  end

  def location
  	@locations = Location.all
  end

  def data
  end

  def prediction
  end
end
