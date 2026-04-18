extends Node2D

@onready var camera_2d = $Camera2D
@onready var osm_tilemap = $OSMTileMap
@onready var player_marker = $PlayerMarker
@onready var info_label = $UI/InfoLabel

var current_latitude: float = 46.0780  # Cividale del Friuli
var current_longitude: float = 13.2330
var current_zoom: int = 15
var tile_sprites: Dictionary = {}  # Sprite2D per visualizzare tiles

func _ready():
	print("Map scene initialized")
	info_label.text = "Furlan Go - Cividale del Friuli\nLat: " + str(current_latitude) + " Lon: " + str(current_longitude)
	
	# Connetti segnali MapManager
	MapManager.map_loaded.connect(_on_map_loaded)
	MapManager.tile_loaded.connect(_on_tile_loaded)
	
	# Carica mappa
	MapManager.load_map(current_latitude, current_longitude, current_zoom)

func _on_map_loaded():
	print("Map loaded")
	_center_camera_on_location()

func _on_tile_loaded(x: int, y: int, zoom: int):
	print("Tile loaded: ", x, ", ", y, ", zoom: ", zoom)
	_display_tile(x, y, zoom)

func _display_tile(x: int, y: int, zoom: int):
	var texture = MapManager.get_tile_texture(x, y, zoom)
	if texture == null:
		return
	
	var tile_key = str(x) + "_" + str(y) + "_" + str(zoom)
	
	# Se lo sprite esiste già, aggiorna texture
	if tile_sprites.has(tile_key):
		tile_sprites[tile_key].texture = texture
		return
	
	# Crea nuovo sprite per la tile
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position = _tile_to_world_position(x, y, zoom)
	osm_tilemap.add_child(sprite)
	tile_sprites[tile_key] = sprite

func _tile_to_world_position(x: int, y: int, zoom: int) -> Vector2:
	var tile_size = 256.0  # Dimensione standard tile OSM
	var center_x = MapManager._lon_to_tile_x(MapManager.center_longitude, zoom)
	var center_y = MapManager._lat_to_tile_y(MapManager.center_latitude, zoom)
	
	var offset_x = (x - center_x) * tile_size
	var offset_y = (y - center_y) * tile_size
	
	return Vector2(640 + offset_x, 360 + offset_y)  # Centra nella viewport

func _center_camera_on_location():
	camera_2d.position = Vector2(640, 360)
	camera_2d.zoom = Vector2(1.0 / current_zoom, 1.0 / current_zoom)

func _process(_delta):
	# TODO: Update camera position based on GPS
	pass

func update_player_position(lat: float, lon: float):
	current_latitude = lat
	current_longitude = lon
	info_label.text = "Furlan Go - Cividale del Friuli\nLat: " + str(current_latitude) + " Lon: " + str(current_longitude)
	MapManager.load_map(lat, lon, current_zoom)

func set_zoom_level(zoom: int):
	current_zoom = zoom
	camera_2d.zoom = Vector2(1.0 / zoom, 1.0 / zoom)
	MapManager.load_map(current_latitude, current_longitude, zoom)

func change_map_style(style_name: String):
	MapManager.set_map_style(style_name)
	# Ricarica tiles con nuovo stile
	_clear_tiles()
	MapManager.load_map(current_latitude, current_longitude, current_zoom)

func _clear_tiles():
	for tile_key in tile_sprites:
		tile_sprites[tile_key].queue_free()
	tile_sprites.clear()
