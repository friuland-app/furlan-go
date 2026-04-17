extends Node

# Map Manager singleton per gestire OpenStreetMap tiles
signal map_loaded
signal tile_loaded(x, y, zoom)

var osm_tilemap: Node2D
var current_zoom: int = 15
var center_latitude: float = 46.0780  # Cividale del Friuli
var center_longitude: float = 13.2330
var base_url: String = "https://a.tile.openstreetmap.org"

func _ready():
	print("MapManager initialized for Cividale del Friuli")

func load_map(lat: float, lon: float, zoom_level: int):
	current_zoom = zoom_level
	center_latitude = lat
	center_longitude = lon
	
	# TODO: Implementare caricamento tiles OSM
	print("Loading map at lat: ", lat, ", lon: ", lon, ", zoom: ", zoom_level)
	map_loaded.emit()

func get_cividale_center() -> Vector2:
	return Vector2(center_latitude, center_longitude)

func set_map_style(style_url: String):
	base_url = style_url
	print("Map style changed to: ", base_url)
