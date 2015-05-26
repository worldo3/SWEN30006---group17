require 'nokogiri'
require 'open-uri'

require 'rubygems'  
require 'rufus/scheduler'

GOVURL = 'http://www.bom.gov.au/vic/observations/melbourne.shtml' 
POSTCODE ='https://bitbucket.org/IvanKruchkoff/misc/raw/4738589aa0d9d3477813734db050eaead8476e56/postcodes/postcodes_pretty_print.json'
API_KEY = '8ffc62bb336a5fae1a96e1ac9a950b8b'  
TIME = Time.now.to_i 

#regex
lat_regex = /Lat: -?\d*.?\d*/
lon_regex = /Lon: -?\d*.?\d*/

#arrays
id_arr = Array.new 
url_arr = Array.new 
lat_long_arr = Array.new 

doc = Nokogiri::HTML(open(GOVURL))
melbourne = doc.css('#tMELBOURNE')
datas = melbourne.css('tr').select{|place| 
place['class'] == 'rowleftcolumn' || place['class'] == 'contrast'}

length = datas.length - 1

for i in 0..length
	data = datas[i]
	all = Location.all
	tempLocation = Location.new
	tempDesc = Description.new
	#id of the location for its description
	tempId = 0
	#counter: 0 = didnt exist in database, 1 means exist
	counter = 0 

	#inserting place name
	location = data.css('th').text
	#check whether location name already exist in database
	all.each do |place|
		if place.location_id == location
			tempLocation = place
			counter = 1
			break
		end
	end

	#if location name is new
	if counter == 0
		tempLocation.location_id = location
		tempLocation.save
	end

	tempId = tempLocation.id
	id_arr.push(tempId)

	tempDesc.location_id = tempId

	#inputing rainfall
	temp = data.css('td')[12].text
	if (temp == "-")
		tempDesc.rainfall = nil
	else
		tempDesc.rainfall = temp.to_f
	end

	#inputing temperature
	temp = data.css('td')[1].text
	if (temp == "-")
		tempDesc.temp = nil
	else
		tempDesc.temp = temp.to_f
	end

	#inputing wind speed
	tempDesc.windSpeed = data.css('td')[7].text.to_f

	#inputing wind direction
	tempDesc.windDirection = data.css('td')[6].text

	#inputing time
	tempDesc.datetime = Time.now

	#url in bom that holds the lat and long of the location
	area_url = data.css('a')[0]['href']
	url_arr.push("http://www.bom.gov.au#{area_url}")

	tempDesc.save
end

#counter for id_array
id_count = 0;

url_arr.each {|url|
	#getting lat and lon
	area_doc = Nokogiri::HTML(open(url))
	area_data = area_doc.css('table')[0]
	lon = lon_regex.match(area_data.text)[0]
	lon = lon[5..lon.length].to_f
	lat = lat_regex.match(area_data.text)[0]
	lat = lat[5..lat.length].to_f

	#get the correct location from database
	number = id_arr[id_count]
	new_location = Location.find(number)
	new_location.lat = lat
	new_location.long = lon

	postcode = JSON.parse(open("#{POSTCODE}").read);

	min_diff = 999
	code = 3000
	for i in 3000..3999
		if postcode["#{i}"].nil?
		else
			data = postcode["#{i}"]["suburbs"]
			count =  data.length
			for j in 0..data.length-1
				lat_diff = (lat - data[j]['geo_lat'].to_f).abs
				lon_diff = (lon - data[j]['geo_long'].to_f).abs
				diff = lat_diff + lon_diff
				if (diff < min_diff)
					min_diff = diff
					code = i
				end
			end
		end
	end
	new_location.post_code = code
	new_location.latest_update = Time.now
	new_location.save
	id_count = id_count + 1
}






















