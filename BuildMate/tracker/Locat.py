import phonenumbers
from phonenumbers import geocoder, carrier
from opencage.geocoder import OpenCageGeocode
from test import number
import folium

# Initialize OpenCage API
key = "542e984148314fc39ed91cb9bd8b024d"
geocoder_api = OpenCageGeocode(key)

# Parse the phone number and extract location and carrier info
check_number = phonenumbers.parse(number, "US")
number_location = geocoder.description_for_number(check_number, "en")
print("Location:", number_location)

service_provider = carrier.name_for_number(check_number, "en")
print("Carrier:", service_provider)

# Forward geocode the location name to get coordinates
query = str(number_location)
results = geocoder_api.geocode(query)
lat = results[0]['geometry']['lat']
lng = results[0]['geometry']['lng']
print("Latitude:", lat, "Longitude:", lng)

# Reverse geocode the coordinates to get a full address
reverse_results = geocoder_api.reverse_geocode(lat, lng)
address = reverse_results[0]['formatted']
print("Address:", address)

# Generate a map with a marker and save as HTML
map = folium.Map(location=[lat, lng], zoom_start=10)
folium.Marker([lat, lng], popup=address).add_to(map)
map.save("location_map.html")