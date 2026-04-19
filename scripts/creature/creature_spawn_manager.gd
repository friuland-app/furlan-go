extends Node

# Creature Spawn Manager - gestisce spawn delle creature sulla mappa
signal creature_spawned(creature_id: String, creature_data: Dictionary)
signal creature_despawned(creature_id: String)
signal creature_interactable(creature_id: String)
signal creature_out_of_range(creature_id: String)

var spawned_creatures: Dictionary = {}  # creature_id → dati creature
var player_position: Vector2 = Vector2.ZERO
var interaction_radius: float = 50.0  # Metri

# Tipi di creature disponibili
var creature_types: Dictionary = {
	"dragon": {
		"name": "Dragone del Friuli",
		"spawn_conditions": {
			"time_of_day": "day",
			"weather": "clear",
			"zone_types": ["historical", "center"]
		},
		"marker_color": Color(1.0, 0.3, 0.3),
		"rarity": "legendary"
	},
	"warrior": {
		"name": "Guerriero Longobardo",
		"spawn_conditions": {
			"time_of_day": "any",
			"weather": "any",
			"zone_types": ["historical", "center"]
		},
		"marker_color": Color(0.3, 0.6, 1.0),
		"rarity": "common"
	},
	"water_spirit": {
		"name": "Spirito del Natisone",
		"spawn_conditions": {
			"time_of_day": "night",
			"weather": "any",
			"zone_types": ["water"]
		},
		"marker_color": Color(0.2, 0.8, 0.8),
		"rarity": "rare"
	},
	"devil_boss": {
		"name": "Demone del Ponte",
		"spawn_conditions": {
			"time_of_day": "night",
			"weather": "storm",
			"zone_types": ["boss"]
		},
		"marker_color": Color(0.8, 0.2, 0.8),
		"rarity": "boss"
	},
	"river_monster": {
		"name": "Mostro del Fiume",
		"spawn_conditions": {
			"time_of_day": "any",
			"weather": "any",
			"zone_types": ["water"]
		},
		"marker_color": Color(0.4, 0.4, 0.8),
		"rarity": "uncommon"
	}
}

func _ready():
	print("Creature Spawn Manager initialized")
	
	# Connetti a GPS updates
	if PlayerLocationManager:
		PlayerLocationManager.player_position_changed.connect(_on_player_position_changed)
	
	# Connetti a zone events
	if GeofenceManager:
		GeofenceManager.zone_entered.connect(_on_zone_entered)
		GeofenceManager.zone_event_triggered.connect(_on_zone_event_triggered)

func _on_player_position_changed(latitude: float, longitude: float):
	player_position = Vector2(latitude, longitude)
	_check_creature_interactions()

func _on_zone_entered(zone_id: String, zone_name: String):
	var zone_data = GeofenceManager.get_zone_data(zone_id)
	if zone_data.has("event_type") and zone_data.event_type == "spawn_creature":
		_spawn_creature_in_zone(zone_id, zone_data)

func _on_zone_event_triggered(zone_id: String, event_type: String):
	if event_type == "spawn_creature":
		var zone_data = GeofenceManager.get_zone_data(zone_id)
		_spawn_creature_in_zone(zone_id, zone_data)
	elif event_type == "boss_spawn":
		var zone_data = GeofenceManager.get_zone_data(zone_id)
		_spawn_boss_in_zone(zone_id, zone_data)
	elif event_type == "water_creature":
		var zone_data = GeofenceManager.get_zone_data(zone_id)
		_spawn_water_creature_in_zone(zone_id, zone_data)

func _spawn_creature_in_zone(zone_id: String, zone_data: Dictionary):
	if not zone_data.has("creature_types"):
		return
	
	var available_creatures = zone_data.creature_types
	var selected_type = available_creatures[randi() % available_creatures.size()]
	
	_spawn_creature(selected_type, zone_data.center_lat, zone_data.center_lon, zone_id)

func _spawn_boss_in_zone(zone_id: String, zone_data: Dictionary):
	if not zone_data.has("boss_type"):
		return
	
	_spawn_creature(zone_data.boss_type, zone_data.center_lat, zone_data.center_lon, zone_id)

func _spawn_water_creature_in_zone(zone_id: String, zone_data: Dictionary):
	if not zone_data.has("creature_types"):
		return
	
	var available_creatures = zone_data.creature_types
	var selected_type = available_creatures[randi() % available_creatures.size()]
	
	_spawn_creature(selected_type, zone_data.center_lat, zone_data.center_lon, zone_id)

func _spawn_creature(creature_type: String, lat: float, lon: float, zone_id: String = ""):
	if not creature_types.has(creature_type):
		print("Unknown creature type: ", creature_type)
		return
	
	# Verifica condizioni spawn
	if not _check_spawn_conditions(creature_type):
		print("Spawn conditions not met for: ", creature_type)
		return
	
	# Crea ID univoco per la creatura
	var creature_id = creature_type + "_" + str(randi()) + "_" + str(Time.get_unix_time_from_system())
	
	# Dati creatura
	var creature_data = {
		"id": creature_id,
		"type": creature_type,
		"name": creature_types[creature_type].name,
		"latitude": lat,
		"longitude": lon,
		"zone_id": zone_id,
		"spawn_time": Time.get_unix_time_from_system(),
		"rarity": creature_types[creature_type].rarity,
		"marker_color": creature_types[creature_type].marker_color,
		"is_interactable": false
	}
	
	spawned_creatures[creature_id] = creature_data
	
	print("Spawned creature: ", creature_data.name, " at ", lat, ", ", lon)
	creature_spawned.emit(creature_id, creature_data)
	
	# Salva su Firebase
	_save_creature_to_firebase(creature_id, creature_data)

func _check_spawn_conditions(creature_type: String) -> bool:
	var type_data = creature_types[creature_type]
	var conditions = type_data.spawn_conditions
	
	# Verifica orario
	if conditions.has("time_of_day"):
		var current_time = _get_time_of_day()
		if conditions.time_of_day != "any" and conditions.time_of_day != current_time:
			return false
	
	# Verifica meteo (opzionale)
	if conditions.has("weather") and conditions.weather != "any":
		var current_weather = _get_weather()
		if conditions.weather != current_weather:
			return false
	
	return true

func _get_time_of_day() -> String:
	var hour = Time.get_datetime_dict_from_system().hour
	
	if hour >= 6 and hour < 18:
		return "day"
	else:
		return "night"

func _get_weather() -> String:
	# Placeholder per API meteo
	# In produzione, integrare API meteo reale
	return "clear"

func _check_creature_interactions():
	for creature_id in spawned_creatures:
		var creature = spawned_creatures[creature_id]
		var distance = _calculate_distance(player_position.x, player_position.y, creature.latitude, creature.longitude)
		
		if distance <= interaction_radius:
			if not creature.is_interactable:
				creature.is_interactable = true
				creature_interactable.emit(creature_id)
		else:
			if creature.is_interactable:
				creature.is_interactable = false
				creature_out_of_range.emit(creature_id)

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

func _save_creature_to_firebase(creature_id: String, creature_data: Dictionary):
	print("Saving creature to Firebase: ", creature_id)
	# TODO: Implementare salvataggio su Firebase Firestore
	# Utilizzando Firebase Admin SDK dal backend

func despawn_creature(creature_id: String):
	if spawned_creatures.has(creature_id):
		spawned_creatures.erase(creature_id)
		creature_despawned.emit(creature_id)
		print("Despawned creature: ", creature_id)

func get_creature_data(creature_id: String) -> Dictionary:
	if spawned_creatures.has(creature_id):
		return spawned_creatures[creature_id]
	return {}

func get_all_creatures() -> Dictionary:
	return spawned_creatures

func get_creatures_near_position(lat: float, lon: float, radius: float) -> Array:
	var nearby_creatures = []
	
	for creature_id in spawned_creatures:
		var creature = spawned_creatures[creature_id]
		var distance = _calculate_distance(lat, lon, creature.latitude, creature.longitude)
		
		if distance <= radius:
			nearby_creatures.append(creature_id)
	
	return nearby_creatures

func set_interaction_radius(radius: float):
	interaction_radius = radius
	print("Interaction radius set to: ", interaction_radius, " meters")

func clear_all_creatures():
	var creature_ids = spawned_creatures.keys()
	for creature_id in creature_ids:
		despawn_creature(creature_id)
