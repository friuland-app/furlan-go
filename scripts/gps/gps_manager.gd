extends Node

# GPS Manager singleton per gestire geolocalizzazione
signal location_updated(latitude: float, longitude: float, accuracy: float)
signal location_error(error: String)
signal permission_granted
signal permission_denied

var current_latitude: float = 46.0780  # Default Cividale del Friuli
var current_longitude: float = 13.2330
var current_accuracy: float = 0.0
var is_location_service_available: bool = false
var is_permission_granted: bool = false

# Per Android
var android_location_manager = null
var location_listener = null

func _ready():
	print("GPS Manager initialized")
	_check_location_service_availability()

func _check_location_service_availability():
	if OS.get_name() == "Android":
		_check_android_location_service()
	else:
		# Fallback per desktop testing
		is_location_service_available = true
		print("Location service available (desktop fallback)")

func _check_android_location_service():
	# Verifica se il servizio di localizzazione è disponibile su Android
	# Questo richiede plugin Android specifico
	print("Checking Android location service...")
	
	# Placeholder per implementazione Android
	# In produzione, useresti plugin come godot-android-plugin o codice nativo
	is_location_service_available = true
	print("Android location service check: ", is_location_service_available)

func request_location_permission():
	if OS.get_name() == "Android":
		_request_android_location_permission()
	else:
		# Desktop non richiede permessi
		is_permission_granted = true
		permission_granted.emit()
		print("Location permission granted (desktop)")

func _request_android_location_permission():
	# Richiedi permessi di localizzazione su Android
	# Questo richiede plugin Android specifico
	print("Requesting Android location permission...")
	
	# Placeholder per implementazione Android
	is_permission_granted = true
	permission_granted.emit()
	print("Android location permission granted")

func start_location_updates():
	if not is_location_service_available:
		location_error.emit("Location service not available")
		return
	
	if not is_permission_granted:
		request_location_permission()
		return
	
	if OS.get_name() == "Android":
		_start_android_location_updates()
	else:
		# Simulazione GPS per desktop testing
		_start_desktop_simulation()

func _start_android_location_updates():
	# Avvia aggiornamenti GPS su Android
	# Questo richiede plugin Android specifico
	print("Starting Android location updates...")
	
	# Placeholder per implementazione Android
	# In produzione, useresti Android LocationManager API

func _start_desktop_simulation():
	# Simulazione GPS per desktop testing
	print("Starting desktop GPS simulation")
	
	# Simula movimento casuale
	_simulate_gps_movement()

func _simulate_gps_movement():
	# Simula movimento GPS per testing desktop
	var timer = Timer.new()
	timer.wait_time = 2.0  # Aggiorna ogni 2 secondi
	timer.timeout.connect(_update_simulated_location)
	add_child(timer)
	timer.start()

func _update_simulated_location():
	# Simula leggero movimento intorno a Cividale del Friuli
	var lat_offset = (randf() - 0.5) * 0.001
	var lon_offset = (randf() - 0.5) * 0.001
	
	current_latitude += lat_offset
	current_longitude += lon_offset
	current_accuracy = 10.0 + randf() * 5.0
	
	location_updated.emit(current_latitude, current_longitude, current_accuracy)
	print("Simulated GPS update: ", current_latitude, ", ", current_longitude)

func stop_location_updates():
	if OS.get_name() == "Android":
		_stop_android_location_updates()
	else:
		_stop_desktop_simulation()

func _stop_android_location_updates():
	# Ferma aggiornamenti GPS su Android
	print("Stopping Android location updates")
	# Placeholder per implementazione Android

func _stop_desktop_simulation():
	print("Stopping desktop GPS simulation")
	# Ferma timer di simulazione

func get_current_location() -> Dictionary:
	return {
		"latitude": current_latitude,
		"longitude": current_longitude,
		"accuracy": current_accuracy
	}

func set_location_for_testing(lat: float, lon: float):
	# Funzione per testing manuale della posizione
	current_latitude = lat
	current_longitude = lon
	current_accuracy = 5.0
	location_updated.emit(lat, lon, current_accuracy)
	print("Location set for testing: ", lat, ", ", lon)
