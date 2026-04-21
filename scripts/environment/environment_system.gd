extends Node

# Environment System - gestisce meteo e orario
signal weather_changed(weather_type: String)
signal time_changed(hour: int)

var current_weather: String = "clear"
var current_hour: int = 12
var weather_api_key: String = ""

func _ready():
	print("Environment System initialized")
	_update_time()
	_fetch_weather()

func _update_time():
	var datetime = Time.get_datetime_dict_from_system()
	current_hour = datetime.hour
	time_changed.emit(current_hour)

func _fetch_weather():
	print("Fetching weather from OpenWeatherMap")
	# Placeholder per API call OpenWeatherMap
	current_weather = "clear"
	weather_changed.emit(current_weather)

func get_creature_spawn_modifier() -> Dictionary:
	var modifier = {}
	
	if current_weather == "rain":
		modifier["water_boost"] = 2.0
	elif current_hour >= 20 or current_hour < 6:
		modifier["darkness_boost"] = 1.5
		modifier["legend_boost"] = 1.3
	elif current_weather == "fog":
		modifier["rare_boost"] = 2.0
	
	return modifier

func get_map_visual_theme() -> String:
	match current_weather:
		"rain":
			return "rainy_theme"
		"cloudy":
			return "cloudy_theme"
		"fog":
			return "foggy_theme"
		_:
			return "default_theme"

func get_seasonal_event() -> String:
	var month = Time.get_datetime_dict_from_system().month
	
	match month:
		12, 1, 2:
			return "winter_event"
		3, 4, 5:
			return "spring_event"
		6, 7, 8:
			return "summer_event"
		9, 10, 11:
			return "autumn_event"
		_:
			return ""
