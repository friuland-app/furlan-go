extends Node

# GPS Manager singleton per gestire geolocalizzazione
signal location_updated(latitude: float, longitude: float, accuracy: float)
signal location_error(error: String)
signal permission_granted
signal permission_denied
signal gps_unavailable
signal gps_disabled

var current_latitude: float = 46.0780  # Default Cividale del Friuli
var current_longitude: float = 13.2330
var current_accuracy: float = 0.0
var is_location_service_available: bool = false
var is_permission_granted: bool = false
var is_gps_enabled: bool = true
var update_interval: float = 2.0  # Secondi tra aggiornamenti GPS
var is_updating: bool = false

# Per Android
var android_location_manager = null
var location_listener = null
var update_timer: Timer = null

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

func set_update_interval(seconds: float):
	update_interval = seconds
	if is_updating and update_timer:
		update_timer.wait_time = update_interval
	print("GPS update interval set to: ", update_interval, " seconds")

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
	# In produzione, useresti Android PermissionManager
	is_permission_granted = true
	permission_granted.emit()
	print("Android location permission granted")

func start_location_updates():
	if not is_location_service_available:
		gps_unavailable.emit()
		location_error.emit("Location service not available")
		return
	
	if not is_gps_enabled:
		gps_disabled.emit()
		location_error.emit("GPS is disabled")
		return
	
	if not is_permission_granted:
		request_location_permission()
		return
	
	if is_updating:
		print("GPS updates already running")
		return
	
	is_updating = true
	
	if OS.get_name() == "Android":
		_start_android_location_updates()
	else:
		# Simulazione GPS per desktop testing
		_start_desktop_simulation()

func _start_android_location_updates():
	# Avvia aggiornamenti GPS su Android
	# Questo richiede plugin Android specifico
	print("Starting Android location updates with interval: ", update_interval, "s")
	
	# Placeholder per implementazione Android
	# In produzione, useresti Android LocationManager API
	# con setMaxUpdateAgeMillis o setIntervalMillis
	
	# Per ora, usa timer come fallback
	_start_location_timer()

func _start_desktop_simulation():
	# Simulazione GPS per desktop testing
	print("Starting desktop GPS simulation with interval: ", update_interval, "s")
	_start_location_timer()

func _start_location_timer():
	# Crea timer per aggiornamenti GPS
	if update_timer:
		update_timer.queue_free()
	
	update_timer = Timer.new()
	update_timer.wait_time = update_interval
	update_timer.autostart = true
	update_timer.timeout.connect(_on_location_timer_timeout)
	add_child(update_timer)
	print("GPS timer started with interval: ", update_interval, "s")

func _on_location_timer_timeout():
	if OS.get_name() == "Android":
		_update_android_location()
	else:
		_update_simulated_location()

func _update_android_location():
	# Aggiorna posizione GPS su Android
	# Placeholder per implementazione Android
	# In produzione, useresti Android LocationListener
	print("Android location update (placeholder)")

func _update_simulated_location():
	# Simula leggero movimento intorno a Cividale del Friuli
	if not is_gps_enabled:
		return
	
	var lat_offset = (randf() - 0.5) * 0.0001
	var lon_offset = (randf() - 0.5) * 0.0001
	
	current_latitude += lat_offset
	current_longitude += lon_offset
	current_accuracy = 5.0 + randf() * 10.0
	
	location_updated.emit(current_latitude, current_longitude, current_accuracy)
	print("Simulated GPS update: ", current_latitude, ", ", current_longitude, " accuracy: ", current_accuracy)

func stop_location_updates():
	if not is_updating:
		print("GPS updates not running")
		return
	
	is_updating = false
	
	if update_timer:
		update_timer.stop()
		update_timer.queue_free()
		update_timer = null
	
	if OS.get_name() == "Android":
		_stop_android_location_updates()
	else:
		print("Desktop GPS simulation stopped")

func _stop_android_location_updates():
	# Ferma aggiornamenti GPS su Android
	print("Stopping Android location updates")
	# Placeholder per implementazione Android

func check_gps_status():
	# Verifica stato GPS
	if not is_location_service_available:
		gps_unavailable.emit()
		return false
	
	if not is_gps_enabled:
		gps_disabled.emit()
		return false
	
	return true

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
