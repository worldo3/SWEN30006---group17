class WeathersController < ApplicationController

  def index
  end

  def location
  	@locations = Location.all
  	time = Time.now
  	@date = time.strftime("%d-%m-%y")
  end

  def data
    if params[:by_location]
      @result = "by_location"
      @name = params[:by_location]
      @locations = Location.where("location_id LIKE ?", "%#{params[:by_location]}%")
      @descriptions = Description.all
    elsif params[:by_postcode]
      @result = "by_postcode"
      @name = params[:by_postcode].to_i
      @locations = Location.where("post_code = '%i' ", "#{@name}")
      @descriptions = Description.all
    end
  end

  def prediction
  end

  def data_form
    @locations = Location.all
    @descriptions = Description.all
  end
end
