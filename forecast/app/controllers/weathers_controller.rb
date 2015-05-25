class WeathersController < ApplicationController

  def index
  end

  def location
  	@locations = Location.all
  	time = Time.now
  	@date = time.strftime("%d-%m-%y")
  end

  def data
    @locations = Location.where("location_id LIKE ?", "%#{params[:by_location]}%")
    @descriptions = Description.all
  end

  def prediction
  end

  def data_form
    @locations = Location.all
    @descriptions = Description.all
  end
end
