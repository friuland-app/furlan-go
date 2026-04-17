extends Node2D

@onready var camera_2d = $Camera2D
@onready var osm_tilemap = $OSMTileMap
@onready var player_marker = $PlayerMarker
@onready var info_label = $UI/InfoLabel

var current_latitude: float = 46.0780  # Cividale del Friuli
var current_longitude: float = 13.2330
var current_zoom: int = 15

func _ready():
	print("Map scene initialized")
	info_label.text = "Furlan Go - Cividale del Friuli\nLat: " + str(current_latitude) + " Lon: " + str(current_longitude)
	
	# TODO: Integrate OSM TileMap plugin
	# TODO: Get GPS location from device

func _process(_delta):
	# TODO: Update camera position based on GPS
	pass

func update_player_position(lat: float, lon: float):
	current_latitude = lat
	current_longitude = lon
	info_label.text = "Furlan Go - Cividale del Friuli\nLat: " + str(current_latitude) + " Lon: " + str(current_longitude)

func set_zoom_level(zoom: int):
	current_zoom = zoom
	camera_2d.zoom = Vector2(1.0 / zoom, 1.0 / zoom)
