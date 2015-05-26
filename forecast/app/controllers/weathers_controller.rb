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

      #find current temperature
      now = Time.now
      min_difference = 999999
      @current_temp = nil
      @locations.each do |location| 
        @descriptions.each do |forecast|
          if forecast.location_id == location.id
            if (now - forecast.datetime) < 1800 && (now-forecast.datetime) < min_difference
              @current_temp = forecast.temp.to_s
              @min_difference = now - forecast.datetime
            end
          end
        end
      end


    elsif params[:by_postcode]
      @result = "by_postcode"
      @name = params[:by_postcode].to_i
      @locations = Location.where("post_code = '%i' ", "#{@name}")
      if @locations.all? &:blank?
        @name = "#{@name} - There is no weather station in this postcode area stored in our database. Please try again."
      end
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
