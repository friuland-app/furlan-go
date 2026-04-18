extends Node

# Player Location Manager - wrapper per GPSManager specifico per il giocatore
signal player_position_changed(latitude: float, longitude: float)
signal player_position_error(error: String)
signal gps_status_changed(status: String)

var gps_manager: Node
var last_known_latitude: float = 46.0780
var last_known_longitude: float = 13.2330
var position_history: Array = []  # Storico posizioni
var max_history_size: int = 100
var is_tracking: bool = false

func _ready():
	gps_manager = GPSManager
	
	# Connetti segnali GPSManager
	gps_manager.location_updated.connect(_on_gps_location_updated)
	gps_manager.location_error.connect(_on_gps_location_error)
	gps_manager.permission_granted.connect(_on_gps_permission_granted)
	gps_manager.permission_denied.connect(_on_gps_permission_denied)
	gps_manager.gps_unavailable.connect(_on_gps_unavailable)
	gps_manager.gps_disabled.connect(_on_gps_disabled)
	
	print("Player Location Manager initialized")

func start_tracking():
	if is_tracking:
		print("Already tracking player position")
		return
	
	print("Starting player position tracking")
	gps_manager.request_location_permission()
	is_tracking = true
	gps_status_changed.emit("tracking")

func stop_tracking():
	if not is_tracking:
		print("Not tracking player position")
		return
	
	print("Stopping player position tracking")
	gps_manager.stop_location_updates()
	is_tracking = false
	gps_status_changed.emit("stopped")

func _on_gps_location_updated(latitude: float, longitude: float, accuracy: float):
	last_known_latitude = latitude
	last_known_longitude = longitude
	
	# Aggiorna storico
	_add_to_position_history(latitude, longitude)
	
	# Emetti segnale posizione giocatore
	player_position_changed.emit(latitude, longitude)
	
	print("Player position updated: ", latitude, ", ", longitude, " accuracy: ", accuracy)

func _on_gps_location_error(error: String):
	print("GPS location error: ", error)
	player_position_error.emit(error)

func _on_gps_permission_granted():
	print("GPS permission granted")
	gps_manager.start_location_updates()
	gps_status_changed.emit("permission_granted")

func _on_gps_permission_denied():
	print("GPS permission denied")
	player_position_error.emit("Location permission denied")
	gps_status_changed.emit("permission_denied")

func _on_gps_unavailable():
	print("GPS unavailable")
	player_position_error.emit("GPS service unavailable")
	gps_status_changed.emit("unavailable")

func _on_gps_disabled():
	print("GPS disabled")
	player_position_error.emit("GPS is disabled")
	gps_status_changed.emit("disabled")

func _add_to_position_history(latitude: float, longitude: float):
	var position_entry = {
		"latitude": latitude,
		"longitude": longitude,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	position_history.append(position_entry)
	
	# Mantieni dimensione storico
	if position_history.size() > max_history_size:
		position_history.pop_front()

func get_current_position() -> Dictionary:
	return {
		"latitude": last_known_latitude,
		"longitude": last_known_longitude
	}

func get_position_history() -> Array:
	return position_history

func set_update_interval(seconds: float):
	gps_manager.set_update_interval(seconds)
	print("Player location update interval set to: ", seconds, " seconds")

func force_location_update(latitude: float, longitude: float):
	# Forza aggiornamento posizione (per testing)
	gps_manager.set_location_for_testing(latitude, longitude)
	print("Forced player location update: ", latitude, ", ", longitude)

func get_tracking_status() -> String:
	if not is_tracking:
		return "stopped"
	
	if not gps_manager.is_permission_granted:
		return "awaiting_permission"
	
	if not gps_manager.is_location_service_available:
		return "unavailable"
	
	if not gps_manager.is_gps_enabled:
		return "disabled"
	
	return "tracking"

func calculate_distance_from_point(lat: float, lon: float) -> float:
	# Calcola distanza in metri dalla posizione corrente
	var earth_radius = 6371000.0  # Metri
	
	var lat1_rad = deg_to_rad(last_known_latitude)
	var lon1_rad = deg_to_rad(last_known_longitude)
	var lat2_rad = deg_to_rad(lat)
	var lon2_rad = deg_to_rad(lon)
	
	var dlat = lat2_rad - lat1_rad
	var dlon = lon2_rad - lon1_rad
	
	var a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1_rad) * cos(lat2_rad) * sin(dlon / 2) * sin(dlon / 2)
	var c = 2 * atan2(sqrt(a), sqrt(1 - a))
	
	return earth_radius * c
