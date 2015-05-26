if @result == "by_location"
	json.current_temp @current_temp
	@locations.each do |location|
		json.measurements @descriptions.each do |forecast|
			if forecast.location_id == location.id
				json.time forecast.datetime.strftime("%I:%M:%S%p")
				json.temp forecast.temp
				json.precip forecast.rainfall
				json.wind_direction forecast.windDirection
				json.wind_speed forecast.windSpeed
			end
		end
	end
else
	json.locations @locations do |location|
		json.location_id location.location_id
		json.lat location.lat
		json.lon location.long
		json.last_update location.latest_update.strftime("%I:%M%p %d-%m-%y")
		json.measurements @descriptions.each do |forecast|
			if forecast.location_id == location.id
				json.time forecast.datetime.strftime("%I:%M:%S%p")
				json.temp forecast.temp
				json.precip forecast.rainfall
				json.wind_direction forecast.windDirection
				json.wind_speed forecast.windSpeed
			end
		end
	end
end