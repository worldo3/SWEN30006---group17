require('matrix')

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
      @current_temp = nil
      @locations.each do |location|
        @descriptions.each do |forecast|
          if forecast.location_id == location.id
            if (now - forecast.datetime) < 1800 && (now-forecast.datetime) < min_difference
              @current_temp = forecast.temp.to_s
              @min_difference = now - forecast.datetime
              @location_now = forecast
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
    @locations = Location.all
    @render = false
    @time = Time.now
    @temp_data = Array.new
    @rainfall_data = Array.new
    @windspeed_data = Array.new
    @winddirection_data = Array.new
    @period_data = Array.new
    if params.count > 2
      @render = true
      xy = []
      if params[:by_location]
        @location_name = @locations.find(params[:by_location]).location_id
        descriptions = Description.all.where(location_id: params[:by_location]).order(:datetime)
        @location = @locations.where(id: params[:by_location]).first.location_id
      elsif params[:lat] and params[:long]
        descriptions = Description.all.where(location_id: closest(params[:lat].to_f,params[:long].to_f)).order(:datetime)
        @location = @locations.where(id: closest(params[:lat].to_f,params[:long].to_f)).first.location_id
      else
        descriptions = []
      end
      descriptions.each do |description|
        xy << [(description.datetime.to_time.to_i - Time.now.to_i)/60,description.temp.to_f,description.rainfall,description.windSpeed,description.windDirection,description.location_id]
      end
      xy = xy.select{|x| x[0] > -31}
      @descriptions = xy.clone
      if xy.count == 0
        description = descriptions.first
        xy << [(description.datetime.to_time.to_i - Time.now.to_i)/60,description.temp.to_f,description.rainfall,description.windSpeed,description.windDirection,description.location_id]
      end
      @predictions = test(xy,params[:by_time].to_i,((9*60) - Time.now.seconds_since_midnight/60).to_i)
      (0..@predictions[1].count).map{|x| @predictions.map{|y| y[x]}}.each do |prediction|
        if !prediction[0].nil?
          @period_data.push(prediction[0])
          @temp_data.push(prediction[1])
          @temp_data.push(prediction[2])
          @rainfall_data.push(prediction[3])
          @rainfall_data.push(prediction[4])
          @windspeed_data.push(prediction[5])
          @windspeed_data.push(prediction[6])
          @winddirection_data.push(prediction[7])
          @winddirection_data.push(prediction[8])
        end
      end
    end
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

def variance(input,actual)
  x = 0.to_f
  [input.length,actual.length].min.times do |y|
    x += (input[y].to_f-actual[y].to_f)**2
  end
  variance = x
end

def closest(lat,long)
  closest = Location.all.map{|location| [location.id,((location.lat.to_f - lat)**2 + (location.long.to_f - long)**2)**0.5]}.sort_by{|x| x[1]}[0][0]
end

def unnegate(num)
  if num < 0
    unnegate = 0
  else
    unnegate = num
  end
end

def test(xy_array,time,mins_since_9)
  results = [(0..time/10).map{|x| x*10}]
  if xy_array.count == 1
    (1..4).each do |y|
      results << []
      (time/10 + 1).times {results[-1] << xy_array[0][y]}
      results << (0..time/10).map{|x| 0.9**x}
    end
  elsif xy_array.count == 0
    4.times do
      results << (0..time/10).map{|x| nil}
      results << (0..time/10).map{|x| "N/A"}
    end
  else
    temp = regress_poly(xy_array.map{|x| x[0]},xy_array.map{|x| x[1]},xy_array.count - 2,false)
    results << (0..time/10).map{|x| ((0..temp.count-1).inject(0){|total,i| total + temp[i]*(x**i)}).round(1)}
    results << (0..time/10).map{|y| (1/(1+ Math.exp(regress_poly(xy_array.map{|x| x[0]},xy_array.map{|x| x[1]},xy_array.count - 2,true)))**(y.to_f/10)).round(2)}
    if xy_array.select{|x| x[2] == nil}.count > 0
      results << (0..time/10).map{|x| nil}
    else
      if xy_array.select{|x| x[0] >= mins_since_9}.count > 0 and xy_array.select{|x| x[0] < mins_since_9}.count > 0
        rain_at_9 = xy_array.select{|x| x[0] < mins_since_9}.last[2]
        temp = xy_array.select{|x| x[0] < mins_since_9}.map{|x| x[2]}
        temp.concat(xy_array.select{|x| x[0] >= mins_since_9}.map{|x| x[2] + rain_at_9})
        temp = regress_poly(xy_array.map{|x| x[0]},temp,1,false)
        temp2 = (0..time/10).map{|y| (1/(1+ Math.exp(regress_poly(xy_array.map{|x| x[0]},temp,1,true)))**(y.to_f/10)).round(2)}
        temp = (0..time/10).map{|x| ((0..temp.count-1).inject(0){|total,i| total + temp[i]*(x**i)}).round(1)}
        results << temp.clone
        results << temp2.clone

      else
        temp = regress_poly(xy_array.map{|x| x[0].to_f},xy_array.map{|x| x[2].to_f},1,false) #xy_array.count - 1)
        temp2 = (0..time/10).map{|y| (1/(1+ Math.exp(regress_poly(xy_array.map{|x| x[0].to_f},xy_array.map{|x| x[2].to_f},1,true)))**(y.to_f/10)).round(2)}
        temp = (0..time/10).map{|x| unnegate(((0..temp.count-1).inject(0){|total,i| total + temp[i]*(x**i)}).round(1))}
        if mins_since_9 > -1 and mins_since_9 < time
          temp_at_9 =  temp[(mins_since_9/10).to_i].to_f
          ((mins_since_9/10).to_i..(temp.count-1)).each{|x| temp[x] -= temp_at_9}
        end
        results << temp.clone
        results << temp2.clone

      end
    end
    temp = regress_poly(xy_array.map{|x| x[0]},xy_array.map{|x| x[3]},2,false)
    results << (0..time/10).map{|x| unnegate(((0..temp.count-1).inject(0){|total,i| total + temp[i]*(x**i)}).round(1))}
    results << (0..time/10).map{|y| (1/(1+ Math.exp(regress_poly(xy_array.map{|x| x[0]},xy_array.map{|x| x[3]},2,true)))**(y.to_f/10)).round(2)}
    results << (0..time/10).map{|x| results[5][x] == 0 ? "CALM" : xy_array[xy_array.count -1][4]}
    results << (0..time/10).map{|x| ((1-xy_array.map{|y| y[3]}.uniq.count.to_f/10)**x).round(2)}
  end
  test = results
end

def regress_poly x_array, y_array, degree, variance #Taken from the project sheet. Simple and effective.
  x_data = x_array.map { |x_i| (0..degree).map { |pow| (x_i**pow).to_f } }
  mx = Matrix[*x_data]
  my = Matrix.column_vector(y_array)
  temp = ((mx.t * mx).inv * mx.t * my).transpose.to_a[0]
  if variance
    regress_poly = variance(x_array.map{|x_i| (0...temp.count).inject(0) {|r, i| r + temp[i]*(0..degree).map { |pow| (x_i**pow).to_f }[i]}},y_array)
  else
    regress_poly = temp.clone
  end
end
