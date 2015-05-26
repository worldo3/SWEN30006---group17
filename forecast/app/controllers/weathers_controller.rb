class WeathersController < ApplicationController

  def index
  end

  def location
  	@locations = Location.all
  	time = Time.now
  	@date = time.strftime("%d-%m-%y")
  end

  def data

    @searched_date = params[:by_date]
    @result_date = Array.new
    @descriptions = Description.all
    @descriptions.each do |forecast|
      if forecast.datetime.strftime("%d-%m-%y") == @searched_date
        @result_date.push(forecast)
      end
    end
    if params[:by_location]
      @result = "by_location"
      @name = params[:by_location]
      @locations = Location.where("location_id LIKE ?", "%#{params[:by_location]}%")

      #find current temperature
      now = Time.now
      min_difference = 999999
      @current_temp = "N/A"
      @condition = "N/A"
      @locations.each do |location| 
        @descriptions.each do |forecast|
          if forecast.location_id == location.id
            if (now - forecast.datetime) < 1800 && (now-forecast.datetime) < min_difference
              @current_temp = forecast.temp.to_s
              @min_difference = now - forecast.datetime
              @condition = forecast.condition
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
    end

  end

  def prediction
  end

  def data_form
    @locations = Location.all
    @descriptions = Description.all
    #to be inputed to form
    @dates = Array.new
    @descriptions.each do |forecast|
      @dates.push(forecast.datetime.strftime("%d-%m-%y"))
    end
    @dates = @dates.sort.uniq

    @postcodes = Array.new
    @locations.each do |station|
      @postcodes.push(station.post_code)
    end
    @postcodes = @postcodes.sort.uniq
  end
end
