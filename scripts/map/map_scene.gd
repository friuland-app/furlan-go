extends Node2D

@onready var camera_2d = $Camera2D
@onready var osm_tilemap = $OSMTileMap
@onready var player_marker = $PlayerMarker
@onready var player_avatar = $PlayerAvatar
@onready var zone_visualizer = $ZoneVisualizer
@onready var creature_markers = $CreatureMarkers
@onready var poi_markers = $POIMarkers
@onready var info_label = $UI/InfoLabel

var current_latitude: float = 46.0780  # Cividale del Friuli
var current_longitude: float = 13.2330
var current_zoom: int = 15
var tile_sprites: Dictionary = {}  # Sprite2D per visualizzare tiles
var creature_marker_instances: Dictionary = {}  # creature_id → marker node
var poi_marker_instances: Dictionary = {}  # poi_id → marker node

func _ready():
	print("Map scene initialized")
	info_label.text = "Furlan Go - Cividale del Friuli\nLat: " + str(current_latitude) + " Lon: " + str(current_longitude)
	
	# Connetti segnali MapManager
	MapManager.map_loaded.connect(_on_map_loaded)
	MapManager.tile_loaded.connect(_on_tile_loaded)
	
	# Connetti segnali PlayerLocationManager
	PlayerLocationManager.player_position_changed.connect(_on_player_position_changed)
	PlayerLocationManager.player_position_error.connect(_on_player_position_error)
	PlayerLocationManager.gps_status_changed.connect(_on_gps_status_changed)
	
	# Connetti segnali GeofenceManager
	GeofenceManager.zone_entered.connect(_on_zone_entered)
	GeofenceManager.zone_exited.connect(_on_zone_exited)
	GeofenceManager.zone_event_triggered.connect(_on_zone_event_triggered)
	
	# Connetti segnali CreatureSpawnManager
	CreatureSpawnManager.creature_spawned.connect(_on_creature_spawned)
	CreatureSpawnManager.creature_despawned.connect(_on_creature_despawned)
	CreatureSpawnManager.creature_interactable.connect(_on_creature_interactable)
	CreatureSpawnManager.creature_out_of_range.connect(_on_creature_out_of_range)
	
	# Connetti segnali POIManager
	POIManager.poi_loaded.connect(_on_poi_loaded)
	POIManager.poi_interactable.connect(_on_poi_interactable)
	POIManager.poi_out_of_range.connect(_on_poi_out_of_range)
	POIManager.poi_reward_claimed.connect(_on_poi_reward_claimed)
	POIManager.poi_cooldown_complete.connect(_on_poi_cooldown_complete)
	
	# Avvia tracking posizione giocatore
	PlayerLocationManager.start_tracking()
	
	# Configura frequenza aggiornamenti GPS (5 secondi)
	PlayerLocationManager.set_update_interval(5.0)
	
	# Carica mappa
	MapManager.load_map(current_latitude, current_longitude, current_zoom)

func _on_map_loaded():
	print("Map loaded")
	_center_camera_on_location()
	_initialize_poi_markers()

func _initialize_poi_markers():
	var all_pois = POIManager.get_all_pois()
	for poi_id in all_pois:
		var poi_data = all_pois[poi_id]
		_add_poi_marker(poi_id, poi_data)

func _on_tile_loaded(x: int, y: int, zoom: int):
	print("Tile loaded: ", x, ", ", y, ", zoom: ", zoom)
	_display_tile(x, y, zoom)

func _on_player_position_changed(latitude: float, longitude: float):
	print("Player position changed: ", latitude, ", ", longitude)
	update_player_position(latitude, longitude)
	
	# Aggiorna posizione avatar
	if player_avatar:
		player_avatar.update_from_gps(latitude, longitude)

func _on_player_position_error(error: String):
	print("Player position error: ", error)
	info_label.text = "Furlan Go - Errore GPS: " + error

func _on_gps_status_changed(status: String):
	print("GPS status changed: ", status)
	info_label.text = "Furlan Go - GPS: " + status

func _on_zone_entered(zone_id: String, zone_name: String):
	print("Entered zone: ", zone_name)
	info_label.text = "Furlan Go - Zona: " + zone_name
	
	# Highlight zona sulla mappa
	if zone_visualizer:
		zone_visualizer.highlight_zone(zone_id, true)

func _on_zone_exited(zone_id: String, zone_name: String):
	print("Exited zone: ", zone_name)
	info_label.text = "Furlan Go - Fuori zona: " + zone_name
	
	# Rimuovi highlight
	if zone_visualizer:
		zone_visualizer.highlight_zone(zone_id, false)

func _on_zone_event_triggered(zone_id: String, event_type: String):
	print("Zone event triggered: ", event_type, " in zone: ", zone_id)
	# TODO: Implementare logica specifica per eventi

func _on_creature_spawned(creature_id: String, creature_data: Dictionary):
	print("Creature spawned: ", creature_data.name)
	_add_creature_marker(creature_id, creature_data)

func _on_creature_despawned(creature_id: String):
	print("Creature despawned: ", creature_id)
	_remove_creature_marker(creature_id)

func _on_creature_interactable(creature_id: String):
	print("Creature became interactable: ", creature_id)
	if creature_marker_instances.has(creature_id):
		creature_marker_instances[creature_id].set_interactable(true)

func _on_creature_out_of_range(creature_id: String):
	print("Creature out of range: ", creature_id)
	if creature_marker_instances.has(creature_id):
		creature_marker_instances[creature_id].set_interactable(false)

func _add_creature_marker(creature_id: String, creature_data: Dictionary):
	var marker_scene = load("res://scenes/creature/creature_marker.tscn")
	var marker = marker_scene.instantiate()
	
	marker.setup(creature_id, creature_data)
	
	# Posiziona marker sulla mappa
	var map_position = _lat_lon_to_map_position(creature_data.latitude, creature_data.longitude)
	marker.position = map_position
	
	creature_markers.add_child(marker)
	creature_marker_instances[creature_id] = marker

func _remove_creature_marker(creature_id: String):
	if creature_marker_instances.has(creature_id):
		var marker = creature_marker_instances[creature_id]
		marker.queue_free()
		creature_marker_instances.erase(creature_id)

func _lat_lon_to_map_position(lat: float, lon: float) -> Vector2:
	var center_lat = MapManager.center_latitude
	var center_lon = MapManager.center_longitude
	
	var lat_offset = (lat - center_lat) * 111000.0
	var lon_offset = (lon - center_lon) * 111000.0 * cos(deg_to_rad(center_lat))
	
	var map_scale = 1.0
	return Vector2(640 + lat_offset * map_scale, 360 + lon_offset * map_scale)

func _on_poi_loaded(poi_id: String, poi_data: Dictionary):
	print("POI loaded: ", poi_data.name)
	_add_poi_marker(poi_id, poi_data)

func _on_poi_interactable(poi_id: String):
	print("POI became interactable: ", poi_id)
	if poi_marker_instances.has(poi_id):
		poi_marker_instances[poi_id].set_interactable(true)

func _on_poi_out_of_range(poi_id: String):
	print("POI out of range: ", poi_id)
	if poi_marker_instances.has(poi_id):
		poi_marker_instances[poi_id].set_interactable(false)

func _on_poi_reward_claimed(poi_id: String, reward: Dictionary):
	print("POI reward claimed: ", reward)
	info_label.text = "Ricompensa: " + str(reward.type)
	
	if poi_marker_instances.has(poi_id):
		var remaining = POIManager.get_poi_cooldown_remaining(poi_id)
		poi_marker_instances[poi_id].set_on_cooldown(true, remaining)

func _on_poi_cooldown_complete(poi_id: String):
	print("POI cooldown complete: ", poi_id)
	if poi_marker_instances.has(poi_id):
		poi_marker_instances[poi_id].set_on_cooldown(false)

func _add_poi_marker(poi_id: String, poi_data: Dictionary):
	var marker_scene = load("res://scenes/poi/poi_marker.tscn")
	var marker = marker_scene.instantiate()
	
	marker.setup(poi_id, poi_data)
	
	# Posiziona marker sulla mappa
	var map_position = _lat_lon_to_map_position(poi_data.latitude, poi_data.longitude)
	marker.position = map_position
	
	poi_markers.add_child(marker)
	poi_marker_instances[poi_id] = marker

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
