extends Node

# Geofence Manager - gestisce zone di gioco e rilevamento entrata/uscita
signal zone_entered(zone_id: String, zone_name: String)
signal zone_exited(zone_id: String, zone_name: String)
signal zone_event_triggered(zone_id: String, event_type: String)

var zones: Dictionary = {}  # ID zona → dati zona
var player_current_zone: String = ""
var player_position: Vector2 = Vector2.ZERO

# Zone del Friuli definite come aree di gioco
var friuli_zones: Array = [
	{
		"id": "cividale_center",
		"name": "Centro Cividale",
		"center_lat": 46.0780,
		"center_lon": 13.2330,
		"radius_meters": 500,
		"color": Color(0.2, 0.6, 1.0, 0.3),
		"event_type": "spawn_creature",
		"creature_types": ["dragon", "warrior"]
	},
	{
		"id": "cividale_historical",
		"name": "Zona Storica",
		"center_lat": 46.0750,
		"center_lon": 13.2300,
		"radius_meters": 300,
		"color": Color(0.8, 0.4, 0.2, 0.3),
		"event_type": "special_event",
		"event_name": "patriarch_hunt"
	},
	{
		"id": "pont_del_diavolo",
		"name": "Ponte del Diavolo",
		"center_lat": 46.0720,
		"center_lon": 13.2280,
		"radius_meters": 200,
		"color": Color(0.6, 0.2, 0.8, 0.3),
		"event_type": "boss_spawn",
		"boss_type": "devil_boss"
	},
	{
		"id": "duomo_square",
		"name": "Piazza Duomo",
		"center_lat": 46.0770,
		"center_lon": 13.2320,
		"radius_meters": 150,
		"color": Color(0.4, 0.8, 0.4, 0.3),
		"event_type": "safe_zone",
		"is_safe": true
	},
	{
		"id": "natisone_river",
		"name": "Fiume Natisone",
		"center_lat": 46.0740,
		"center_lon": 13.2350,
		"radius_meters": 400,
		"color": Color(0.2, 0.4, 0.8, 0.3),
		"event_type": "water_creature",
		"creature_types": ["water_spirit", "river_monster"]
	}
]

func _ready():
	print("Geofence Manager initialized")
	_load_friuli_zones()
	
	# Connetti a GPS updates
	if PlayerLocationManager:
		PlayerLocationManager.player_position_changed.connect(_on_player_position_changed)

func _load_friuli_zones():
	for zone_data in friuli_zones:
		zones[zone_data.id] = zone_data
		print("Loaded zone: ", zone_data.name, " at ", zone_data.center_lat, ", ", zone_data.center_lon)

func _on_player_position_changed(latitude: float, longitude: float):
	player_position = Vector2(latitude, longitude)
	_check_zone_entry_exit()

func _check_zone_entry_exit():
	var current_zone_id = _get_zone_at_position(player_position.x, player_position.y)
	
	if current_zone_id != player_current_zone:
		# Uscita dalla zona precedente
		if player_current_zone != "":
			_zone_exited(player_current_zone)
		
		# Entrata nella nuova zona
		if current_zone_id != "":
			_zone_entered(current_zone_id)
		
		player_current_zone = current_zone_id

func _get_zone_at_position(lat: float, lon: float) -> String:
	for zone_id in zones:
		var zone = zones[zone_id]
		var distance = _calculate_distance(lat, lon, zone.center_lat, zone.center_lon)
		
		if distance <= zone.radius_meters:
			return zone_id
	
	return ""

func _calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
	var earth_radius = 6371000.0  # Metri
	
	var lat1_rad = deg_to_rad(lat1)
	var lon1_rad = deg_to_rad(lon1)
	var lat2_rad = deg_to_rad(lat2)
	var lon2_rad = deg_to_rad(lon2)
	
	var dlat = lat2_rad - lat1_rad
	var dlon = lon2_rad - lon1_rad
	
	var a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1_rad) * cos(lat2_rad) * sin(dlon / 2) * sin(dlon / 2)
	var c = 2 * atan2(sqrt(a), sqrt(1 - a))
	
	return earth_radius * c

func _zone_entered(zone_id: String):
	if not zones.has(zone_id):
		return
	
	var zone = zones[zone_id]
	print("Player entered zone: ", zone.name)
	zone_entered.emit(zone_id, zone.name)
	
	# Trigger evento gioco
	_trigger_zone_event(zone_id)

func _zone_exited(zone_id: String):
	if not zones.has(zone_id):
		return
	
	var zone = zones[zone_id]
	print("Player exited zone: ", zone.name)
	zone_exited.emit(zone_id, zone.name)

func _trigger_zone_event(zone_id: String):
	if not zones.has(zone_id):
		return
	
	var zone = zones[zone_id]
	
	if zone.has("event_type"):
		print("Triggering zone event: ", zone.event_type, " for zone: ", zone.name)
		zone_event_triggered.emit(zone_id, zone.event_type)
		
		# Logica specifica per tipo evento
		match zone.event_type:
			"spawn_creature":
				_spawn_creature(zone)
			"boss_spawn":
				_spawn_boss(zone)
			"special_event":
				_start_special_event(zone)
			"safe_zone":
				_enable_safe_zone(zone)
			"water_creature":
				_spawn_water_creature(zone)

func _spawn_creature(zone: Dictionary):
	print("Spawning creatures in zone: ", zone.name)
	# TODO: Implementare spawn creature

func _spawn_boss(zone: Dictionary):
	print("Spawning boss in zone: ", zone.name)
	# TODO: Implementare spawn boss

func _start_special_event(zone: Dictionary):
	print("Starting special event: ", zone.event_name)
	# TODO: Implementare evento speciale

func _enable_safe_zone(zone: Dictionary):
	print("Safe zone enabled: ", zone.name)
	# TODO: Implementare safe zone logic

func _spawn_water_creature(zone: Dictionary):
	print("Spawning water creatures in zone: ", zone.name)
	# TODO: Implementare spawn creature acquatiche

func get_zone_data(zone_id: String) -> Dictionary:
	if zones.has(zone_id):
		return zones[zone_id]
	return {}

func get_all_zones() -> Dictionary:
	return zones

func get_current_zone() -> String:
	return player_current_zone

func is_in_safe_zone() -> bool:
	if player_current_zone == "":
		return false
	
	var zone = zones[player_current_zone]
	if zone.has("is_safe") and zone.is_safe:
		return true
	
	return false

func get_zone_color(zone_id: String) -> Color:
	if zones.has(zone_id) and zones[zone_id].has("color"):
		return zones[zone_id].color
	return Color(1.0, 1.0, 1.0, 0.3)

func add_custom_zone(zone_id: String, zone_data: Dictionary):
	zones[zone_id] = zone_data
	print("Custom zone added: ", zone_id)

func remove_zone(zone_id: String):
	if zones.has(zone_id):
		zones.erase(zone_id)
		print("Zone removed: ", zone_id)
