if params[:by_location]
	json.location_id @location_name
elsif params[:lat] and params[:long]
	json.lattitude params[:lat]
	json.longitude params[:long]
end
json.prediction (0..@predictions[1].count).map{|x| @predictions.map{|y| y[x]}}.each do |prediction|
	if !prediction[0].nil?
		i = 0
		valuecounter = 0
		predictcounter = 0 
		json.period prediction[0]
		json.time @time.strftime("%I:%M%p %d-%m-%y")
		json.rain @rainfall_data do |rainfall|
			if rainfall == @rainfall_data[i] && valuecounter == 0
				json.value rainfall
				valuecounter = 1
			elsif rainfall == @rainfall_data[i+1] && predictcounter == 0
				json.prediction rainfall
				predictcounter = 1
			end
		end
		valuecounter = 0
		predictcounter = 0 
		json.temp @temp_data do |temp|
			if temp == @temp_data[i] && valuecounter == 0
				json.value temp
				valuecounter = 1
			elsif temp == @temp_data[i+1] && predictcounter == 0
				json.prediction temp
				predictcounter = 1
			end
		end
		valuecounter = 0
		predictcounter = 0 
		json.windspeed @windspeed_data do |speed| 
			if speed == @windspeed_data[i] && valuecounter == 0
				json.value speed
				valuecounter = 1
			elsif speed == @windspeed_data[i+1] && predictcounter == 0
				json.prediction speed
				predictcounter = 1
			end
		end
		valuecounter = 0
		predictcounter = 0 
		json.winddirection @winddirection_data do |direction|
			if direction == @winddirection_data[i] && valuecounter == 0
				json.value direction
				valuecounter = 1
			elsif direction == @winddirection_data[i+1] && predictcounter == 0
				json.prediction direction
				predictcounter = 1
			end
		end
		@time = @time + 600
		i = i + 2
	end
end