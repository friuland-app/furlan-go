extends Node

# POI Manager - gestisce Punti di Interesse (POI) come PokéStop equivalenti
signal poi_loaded(poi_id: String, poi_data: Dictionary)
signal poi_interactable(poi_id: String)
signal poi_out_of_range(poi_id: String)
signal poi_reward_claimed(poi_id: String, reward: Dictionary)
signal poi_cooldown_complete(poi_id: String)

var pois: Dictionary = {}  # poi_id → dati POI
var player_position: Vector2 = Vector2.ZERO
var interaction_radius: float = 30.0  # Metri
var cooldown_duration: int = 300  # Secondi (5 minuti)
var poi_cooldowns: Dictionary = {}  # poi_id → timestamp cooldown

# POI del Friuli definiti
var friuli_pois: Array = [
	{
		"id": "duomo_cividale",
		"name": "Duomo di Cividale",
		"description": "Cattedrale medievale con affreschi longobardi",
		"latitude": 46.0770,
		"longitude": 13.2320,
		"type": "religious",
		"icon": "church",
		"reward_type": "items",
		"reward_items": ["potion", "revive"],
		"reward_quantity": 2
	},
	{
		"id": "patriarch_palace",
		"name": "Palazzo Patriarcale",
		"description": "Sede storica dei Patriarchi di Aquileia",
		"latitude": 46.0760,
		"longitude": 13.2300,
		"type": "historical",
		"icon": "castle",
		"reward_type": "items",
		"reward_items": ["scroll", "gem"],
		"reward_quantity": 1
	},
	{
		"id": "devil_bridge",
		"name": "Ponte del Diavolo",
		"description": "Antico ponte romano sul fiume Natisone",
		"latitude": 46.0720,
		"longitude": 13.2280,
		"type": "monument",
		"icon": "bridge",
		"reward_type": "items",
		"reward_items": ["elixir", "key"],
		"reward_quantity": 1
	},
	{
		"id": "longobard_temple",
		"name": "Tempio Longobardo",
		"description": "Uno dei più importanti monumenti longobardi",
		"latitude": 46.0755,
		"longitude": 13.2295,
		"type": "historical",
		"icon": "temple",
		"reward_type": "experience",
		"reward_xp": 100
	},
	{
		"id": "natisone_bank",
		"name": "Lungo Natisone",
		"description": "Passeggiata panoramica sul fiume Natisone",
		"latitude": 46.0740,
		"longitude": 13.2350,
		"type": "nature",
		"icon": "nature",
		"reward_type": "items",
		"reward_items": ["berry", "water"],
		"reward_quantity": 3
	},
	{
		"id": "civic_museum",
		"name": "Museo Civico",
		"description": "Museo con reperti archeologici e storici",
		"latitude": 46.0780,
		"longitude": 13.2310,
		"type": "museum",
		"icon": "museum",
		"reward_type": "experience",
		"reward_xp": 150
	},
	{
		"id": "main_square",
		"name": "Piazza Paolo Diacono",
		"description": "Piazza principale con fontana storica",
		"latitude": 46.0765,
		"longitude": 13.2335,
		"type": "square",
		"icon": "square",
		"reward_type": "items",
		"reward_items": ["coin", "coin"],
		"reward_quantity": 2
	},
	{
		"id": "christian_museum",
		"name": "Museo Cristiano",
		"description": "Museo di arte e cultura cristiana",
		"latitude": 46.0775,
		"longitude": 13.2315,
		"type": "museum",
		"icon": "museum",
		"reward_type": "items",
		"reward_items": ["artifact", "scroll"],
		"reward_quantity": 1
	}
]

func _ready():
	print("POI Manager initialized")
	_load_friuli_pois()
	_load_cooldowns()
	
	# Connetti a GPS updates
	if PlayerLocationManager:
		PlayerLocationManager.player_position_changed.connect(_on_player_position_changed)

func _load_friuli_pois():
	for poi_data in friuli_pois:
		pois[poi_data.id] = poi_data
		pois[poi_data.id]["is_interactable"] = false
		pois[poi_data.id]["is_on_cooldown"] = false
		print("Loaded POI: ", poi_data.name, " at ", poi_data.latitude, ", ", poi_data.longitude)
	
	# Carica POI da Firebase (opzionale)
	_load_pois_from_firebase()

func _load_pois_from_firebase():
	print("Loading POIs from Firebase...")
	# TODO: Implementare caricamento POI da Firebase Firestore
	# Utilizzando Firebase Admin SDK dal backend

func _load_cooldowns():
	# Carica cooldown salvati localmente
	var saved_cooldowns = _get_saved_cooldowns()
	for poi_id in saved_cooldowns:
		var cooldown_end = saved_cooldowns[poi_id]
		if Time.get_unix_time_from_system() < cooldown_end:
			poi_cooldowns[poi_id] = cooldown_end
			if pois.has(poi_id):
				pois[poi_id]["is_on_cooldown"] = true

func _get_saved_cooldowns() -> Dictionary:
	# Placeholder per caricamento salvataggio locale
	# In produzione, usare FileAccess per salvare/caricare
	return {}

func _save_cooldowns():
	# Placeholder per salvataggio locale
	# In produzione, usare FileAccess per salvare
	pass

func _on_player_position_changed(latitude: float, longitude: float):
	player_position = Vector2(latitude, longitude)
	_check_poi_interactions()
	_check_cooldowns()

func _check_poi_interactions():
	for poi_id in pois:
		var poi = pois[poi_id]
		var distance = _calculate_distance(player_position.x, player_position.y, poi.latitude, poi.longitude)
		
		if distance <= interaction_radius:
			if not poi.is_on_cooldown and not poi.is_interactable:
				poi.is_interactable = true
				poi_interactable.emit(poi_id)
		else:
			if poi.is_interactable:
				poi.is_interactable = false
				poi_out_of_range.emit(poi_id)

func _check_cooldowns():
	var current_time = Time.get_unix_time_from_system()
	var cooldowns_to_remove = []
	
	for poi_id in poi_cooldowns:
		if current_time >= poi_cooldowns[poi_id]:
			cooldowns_to_remove.append(poi_id)
	
	for poi_id in cooldowns_to_remove:
		poi_cooldowns.erase(poi_id)
		if pois.has(poi_id):
			pois[poi_id]["is_on_cooldown"] = false
		poi_cooldown_complete.emit(poi_id)
		print("Cooldown complete for POI: ", poi_id)
	
	if cooldowns_to_remove.size() > 0:
		_save_cooldowns()

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

func claim_poi_reward(poi_id: String):
	if not pois.has(poi_id):
		print("POI not found: ", poi_id)
		return
	
	var poi = pois[poi_id]
	
	if poi.is_on_cooldown:
		print("POI on cooldown: ", poi_id)
		return
	
	if not poi.is_interactable:
		print("POI not interactable: ", poi_id)
		return
	
	# Genera ricompensa
	var reward = _generate_reward(poi)
	
	# Imposta cooldown
	var cooldown_end = Time.get_unix_time_from_system() + cooldown_duration
	poi_cooldowns[poi_id] = cooldown_end
	poi.is_on_cooldown = true
	poi.is_interactable = false
	
	# Salva cooldowns
	_save_cooldowns()
	
	print("Reward claimed from POI: ", poi.name)
	poi_reward_claimed.emit(poi_id, reward)

func _generate_reward(poi: Dictionary) -> Dictionary:
	var reward = {
		"poi_name": poi.name,
		"type": poi.reward_type
	}
	
	match poi.reward_type:
		"items":
			reward["items"] = []
			for i in range(poi.reward_quantity):
				var item = poi.reward_items[randi() % poi.reward_items.size()]
				reward["items"].append(item)
		"experience":
			reward["xp"] = poi.reward_xp
		_:
			reward["items"] = ["coin"]
	
	return reward

func get_poi_data(poi_id: String) -> Dictionary:
	if pois.has(poi_id):
		return pois[poi_id]
	return {}

func get_all_pois() -> Dictionary:
	return pois

func get_pois_near_position(lat: float, lon: float, radius: float) -> Array:
	var nearby_pois = []
	
	for poi_id in pois:
		var poi = pois[poi_id]
		var distance = _calculate_distance(lat, lon, poi.latitude, poi.longitude)
		
		if distance <= radius:
			nearby_pois.append(poi_id)
	
	return nearby_pois

func get_poi_cooldown_remaining(poi_id: String) -> int:
	if not poi_cooldowns.has(poi_id):
		return 0
	
	var current_time = Time.get_unix_time_from_system()
	var remaining = int(poi_cooldowns[poi_id] - current_time)
	return max(0, remaining)

func set_interaction_radius(radius: float):
	interaction_radius = radius
	print("POI interaction radius set to: ", interaction_radius, " meters")

func set_cooldown_duration(seconds: int):
	cooldown_duration = seconds
	print("POI cooldown duration set to: ", cooldown_duration, " seconds")

func add_custom_poi(poi_id: String, poi_data: Dictionary):
	pois[poi_id] = poi_data
	pois[poi_id]["is_interactable"] = false
	pois[poi_id]["is_on_cooldown"] = false
	print("Custom POI added: ", poi_id)

func remove_poi(poi_id: String):
	if pois.has(poi_id):
		pois.erase(poi_id)
		print("POI removed: ", poi_id)
