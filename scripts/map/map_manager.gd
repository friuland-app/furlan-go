extends Node

# Map Manager singleton per gestire OpenStreetMap tiles
signal map_loaded
signal tile_loaded(x, y, zoom)

var osm_tilemap: Node2D
var current_zoom: int = 15
var center_latitude: float = 46.0780  # Cividale del Friuli
var center_longitude: float = 13.2330
var base_url: String = "https://a.tile.openstreetmap.org"
var tiles: Dictionary = {}  # Cache delle tiles
var max_tiles_to_load: int = 9  # Numero di tiles da caricare intorno al centro

# Map styles
var map_styles = {
	"standard": "https://a.tile.openstreetmap.org",
	"satellite": "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile",
	"terrain": "https://c.tile.opentopomap.org",
	"dark": "https://a.basemaps.cartocdn.com/dark_all"
}

func _ready():
	print("MapManager initialized for Cividale del Friuli")

func load_map(lat: float, lon: float, zoom_level: int):
	current_zoom = zoom_level
	center_latitude = lat
	center_longitude = lon
	
	print("Loading map at lat: ", lat, ", lon: ", lon, ", zoom: ", zoom_level)
	_load_tiles_around_center()
	map_loaded.emit()

func _load_tiles_around_center():
	# Converti lat/lon in tile coordinates
	var tile_x = _lon_to_tile_x(center_longitude, current_zoom)
	var tile_y = _lat_to_tile_y(center_latitude, current_zoom)
	
	# Carica tiles intorno al centro
	for x_offset in range(-1, 2):
		for y_offset in range(-1, 2):
			var target_x = tile_x + x_offset
			var target_y = tile_y + y_offset
			_load_tile(target_x, target_y, current_zoom)

func _load_tile(x: int, y: int, zoom: int):
	var tile_key = str(x) + "_" + str(y) + "_" + str(zoom)
	
	# Se la tile è già caricata, skip
	if tiles.has(tile_key):
		return
	
	var tile_url = base_url + "/" + str(zoom) + "/" + str(x) + "/" + str(y) + ".png"
	print("Loading tile: ", tile_url)
	
	# Crea HTTP request per scaricare la tile
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_tile_loaded.bind(x, y, zoom, tile_key))
	http_request.request(tile_url)

func _on_tile_loaded(result, response_code, headers, body, x: int, y: int, zoom: int, tile_key: String):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var image = Image.new()
		var error = image.load_png_from_buffer(body)
		if error == OK:
			var texture = ImageTexture.new()
			texture.set_image(image)
			tiles[tile_key] = texture
			tile_loaded.emit(x, y, zoom)
			print("Tile loaded successfully: ", tile_key)
		else:
			print("Error loading PNG from buffer: ", error)
	else:
		print("Error loading tile: ", result, " response code: ", response_code)

func _lon_to_tile_x(lon: float, zoom: int) -> int:
	return int(floor((lon + 180.0) / 360.0 * pow(2.0, zoom)))

func _lat_to_tile_y(lat: float, zoom: int) -> int:
	var lat_rad = deg_to_rad(lat)
	return int(floor((1.0 - asinh(tan(lat_rad)) / PI) / 2.0 * pow(2.0, zoom)))

func get_cividale_center() -> Vector2:
	return Vector2(center_latitude, center_longitude)

func set_map_style(style_name: String):
	if map_styles.has(style_name):
		base_url = map_styles[style_name]
		print("Map style changed to: ", style_name, " - ", base_url)
	else:
		print("Unknown map style: ", style_name)

func get_tile_texture(x: int, y: int, zoom: int) -> Texture2D:
	var tile_key = str(x) + "_" + str(y) + "_" + str(zoom)
	if tiles.has(tile_key):
		return tiles[tile_key]
	return null
