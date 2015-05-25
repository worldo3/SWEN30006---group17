json.date @date
json.locations @locations do |location|
	json.location_id location.location_id
	json.lat location.lat
	json.lon location.long
	json.last_update location.latest_update.strftime("%I:%M%p %d-%m-%y")
end