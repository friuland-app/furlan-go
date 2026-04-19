extends Node

# Performance Manager - gestisce ottimizzazioni per performance e batteria
signal tile_cache_updated(cache_size: int)
signal entity_visibility_changed(visible_count: int)

# Configurazione limiti
var max_visible_tiles: int = 25  # Numero massimo di tile visibili
var max_visible_creatures: int = 10  # Numero massimo di creature visibili
var max_visible_pois: int = 15  # Numero massimo di POI visibili
var gps_update_interval_dynamic: float = 5.0  # Secondi
var gps_update_interval_low_battery: float = 30.0  # Secondi
var tile_cache_size: int = 100  # Numero massimo di tile in cache

# Stato
var current_gps_interval: float = 5.0
var is_low_battery_mode: bool = false
var tile_cache: Dictionary = {}  # tile_key → texture
var visible_creatures: Dictionary = {}  # creature_id → distance
var visible_pois: Dictionary = {}  # poi_id → distance

func _ready():
	print("Performance Manager initialized")
	_apply_initial_settings()

func _apply_initial_settings():
	_set_gps_update_interval(gps_update_interval_dynamic)

func _set_gps_update_interval(interval: float):
	current_gps_interval = interval
	if PlayerLocationManager:
		PlayerLocationManager.set_update_interval(interval)
	print("GPS update interval set to: ", interval, " seconds")

func enable_low_battery_mode():
	if not is_low_battery_mode:
		is_low_battery_mode = true
		_set_gps_update_interval(gps_update_interval_low_battery)
		_reduce_visible_entities()
		print("Low battery mode enabled")

func disable_low_battery_mode():
	if is_low_battery_mode:
		is_low_battery_mode = false
		_set_gps_update_interval(gps_update_interval_dynamic)
		print("Low battery mode disabled")

func _reduce_visible_entities():
	# Riduce il numero di entità visibili in modalità batteria bassa
	max_visible_creatures = max(5, max_visible_creatures / 2)
	max_visible_pois = max(8, max_visible_pois / 2)

func cache_tile(tile_key: String, texture: Texture2D):
	if tile_cache.size() >= tile_cache_size:
		_remove_oldest_tile()
	
	tile_cache[tile_key] = {
		"texture": texture,
		"timestamp": Time.get_unix_time_from_system()
	}
	tile_cache_updated.emit(tile_cache.size())

func get_cached_tile(tile_key: String) -> Texture2D:
	if tile_cache.has(tile_key):
		return tile_cache[tile_key].texture
	return null

func _remove_oldest_tile():
	var oldest_key = ""
	var oldest_time = Time.get_unix_time_from_system()
	
	for key in tile_cache:
		if tile_cache[key].timestamp < oldest_time:
			oldest_time = tile_cache[key].timestamp
			oldest_key = key
	
	if oldest_key != "":
		tile_cache.erase(oldest_key)
		print("Removed oldest tile from cache: ", oldest_key)

func clear_tile_cache():
	tile_cache.clear()
	tile_cache_updated.emit(0)
	print("Tile cache cleared")

func update_visible_entities(player_lat: float, player_lon: float):
	_update_visible_creatures(player_lat, player_lon)
	_update_visible_pois(player_lat, player_lon)

func _update_visible_creatures(player_lat: float, player_lon: float):
	if not CreatureSpawnManager:
		return
	
	var all_creatures = CreatureSpawnManager.get_all_creatures()
	var creature_distances = {}
	
	# Calcola distanze per tutte le creature
	for creature_id in all_creatures:
		var creature = all_creatures[creature_id]
		var distance = _calculate_distance(player_lat, player_lon, creature.latitude, creature.longitude)
		creature_distances[creature_id] = distance
	
	# Ordina per distanza
	var sorted_creatures = creature_distances.keys()
	sorted_creatures.sort_custom(func(a, b): return creature_distances[a] < creature_distances[b])
	
	# Limita al numero massimo visibile
	var visible_count = 0
	visible_creatures.clear()
	
	for creature_id in sorted_creatures:
		if visible_count >= max_visible_creatures:
			break
		
		visible_creatures[creature_id] = creature_distances[creature_id]
		visible_count += 1
	
	entity_visibility_changed.emit(visible_count)

func _update_visible_pois(player_lat: float, player_lon: float):
	if not POIManager:
		return
	
	var all_pois = POIManager.get_all_pois()
	var poi_distances = {}
	
	# Calcola distanze per tutti i POI
	for poi_id in all_pois:
		var poi = all_pois[poi_id]
		var distance = _calculate_distance(player_lat, player_lon, poi.latitude, poi.longitude)
		poi_distances[poi_id] = distance
	
	# Ordina per distanza
	var sorted_pois = poi_distances.keys()
	sorted_pois.sort_custom(func(a, b): return poi_distances[a] < poi_distances[b])
	
	# Limita al numero massimo visibile
	var visible_count = 0
	visible_pois.clear()
	
	for poi_id in sorted_pois:
		if visible_count >= max_visible_pois:
			break
		
		visible_pois[poi_id] = poi_distances[poi_id]
		visible_count += 1
	
	entity_visibility_changed.emit(visible_count)

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

func is_creature_visible(creature_id: String) -> bool:
	return visible_creatures.has(creature_id)

func is_poi_visible(poi_id: String) -> bool:
	return visible_pois.has(poi_id)

func get_cache_size() -> int:
	return tile_cache.size()

func set_max_visible_tiles(max_tiles: int):
	max_visible_tiles = max_tiles
	print("Max visible tiles set to: ", max_tiles)

func set_max_visible_creatures(max_creatures: int):
	max_visible_creatures = max_creatures
	print("Max visible creatures set to: ", max_creatures)

func set_max_visible_pois(max_pois: int):
	max_visible_pois = max_pois
	print("Max visible POIs set to: ", max_pois)

func get_performance_stats() -> Dictionary:
	return {
		"cache_size": tile_cache.size(),
		"visible_creatures": visible_creatures.size(),
		"visible_pois": visible_pois.size(),
		"low_battery_mode": is_low_battery_mode,
		"gps_interval": current_gps_interval
	}
