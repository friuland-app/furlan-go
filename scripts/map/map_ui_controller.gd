extends Control

# Map UI Controller - gestisce l'interfaccia utente della mappa
signal zoom_changed(new_zoom: float)
signal compass_rotation_changed(rotation: float)

var current_zoom: float = 1.0
var min_zoom: float = 0.5
var max_zoom: float = 3.0
var zoom_step: float = 0.1
var exploration_radius: float = 100.0  # Metri

# Riferimenti UI
@onready var zoom_in_button = $ZoomControls/ZoomInButton
@onready var zoom_out_button = $ZoomControls/ZoomOutButton
@onready var center_button = $CenterButton
@onready var compass = $Compass
@onready var exploration_ring = $ExplorationRing
@onready var zoom_label = $ZoomControls/ZoomLabel
@onready var location_label = $LocationLabel

var map_camera: Camera2D = null

func _ready():
	print("Map UI Controller initialized")
	_connect_signals()
	_update_zoom_label()
	_update_compass_rotation()

func set_map_camera(camera: Camera2D):
	map_camera = camera
	if map_camera:
		current_zoom = map_camera.zoom.x
		_update_zoom_label()

func _connect_signals():
	if zoom_in_button:
		zoom_in_button.pressed.connect(_on_zoom_in_pressed)
	
	if zoom_out_button:
		zoom_out_button.pressed.connect(_on_zoom_out_pressed)
	
	if center_button:
		center_button.pressed.connect(_on_center_pressed)

func _on_zoom_in_pressed():
	if map_camera:
		current_zoom = min(current_zoom + zoom_step, max_zoom)
		_apply_zoom()
		zoom_changed.emit(current_zoom)

func _on_zoom_out_pressed():
	if map_camera:
		current_zoom = max(current_zoom - zoom_step, min_zoom)
		_apply_zoom()
		zoom_changed.emit(current_zoom)

func _on_center_pressed():
	print("Centering map on player position")
	if PlayerLocationManager:
		var location = PlayerLocationManager.get_current_position()
		_center_map_on_location(location.latitude, location.longitude)

func _apply_zoom():
	if map_camera:
		map_camera.zoom = Vector2(current_zoom, current_zoom)
		_update_zoom_label()
		_update_exploration_ring()

func _update_zoom_label():
	if zoom_label:
		zoom_label.text = "Zoom: " + str(int(current_zoom * 100)) + "%"

func _center_map_on_location(lat: float, lon: float):
	var map_position = _lat_lon_to_map_position(lat, lon)
	if map_camera:
		map_camera.position = map_position

func _lat_lon_to_map_position(lat: float, lon: float) -> Vector2:
	var center_lat = MapManager.center_latitude
	var center_lon = MapManager.center_longitude
	
	var lat_offset = (lat - center_lat) * 111000.0
	var lon_offset = (lon - center_lon) * 111000.0 * cos(deg_to_rad(center_lat))
	
	var map_scale = 1.0
	return Vector2(640 + lat_offset * map_scale, 360 + lon_offset * map_scale)

func _update_compass_rotation():
	# La bussola punta sempre a nord
	# In produzione, calcolare rotazione basata su orientamento dispositivo
	if compass:
		compass.rotation = 0  # Nord = 0 gradi
		compass_rotation_changed.emit(0)

func _update_exploration_ring():
	if exploration_ring and map_camera:
		# Aggiorna dimensione anello esplorazione basato su zoom
		var ring_size = exploration_radius * current_zoom * 0.01
		exploration_ring.scale = Vector2(ring_size, ring_size)

func set_zoom_level(zoom: float):
	current_zoom = clamp(zoom, min_zoom, max_zoom)
	_apply_zoom()
	zoom_changed.emit(current_zoom)

func get_current_zoom() -> float:
	return current_zoom

func set_exploration_radius(radius: float):
	exploration_radius = radius
	_update_exploration_ring()

func update_location_label(lat: float, lon: float):
	if location_label:
		location_label.text = "Lat: " + str(lat) + "\nLon: " + str(lon)

func _process(_delta):
	# Aggiorna posizione esplorazione ring se necessario
	if exploration_ring and map_camera:
		exploration_ring.position = map_camera.position
