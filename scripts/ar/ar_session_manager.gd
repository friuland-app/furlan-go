extends Node

# AR Session Manager - gestisce la sessione AR in Godot
signal ar_session_started
signal ar_session_failed(error: String)
signal ar_tracking_state_changed(state: String)
signal camera_permission_granted
signal camera_permission_denied

var is_ar_available: bool = false
var is_ar_running: bool = false
var tracking_state: String = "not_tracking"

@onready var status_label = $ARUI/StatusLabel
@onready var tracking_label = $ARUI/TrackingLabel

func _ready():
	print("AR Session Manager initialized")
	
	# Connetti segnali
	ar_session_started.connect(_on_ar_session_started)
	ar_session_failed.connect(_on_ar_session_failed)
	ar_tracking_state_changed.connect(_on_tracking_state_changed)
	camera_permission_granted.connect(_on_camera_permission_granted)
	camera_permission_denied.connect(_on_camera_permission_denied)
	
	_check_ar_availability()

func _on_ar_session_started():
	print("AR session started")
	if status_label:
		status_label.text = "AR Session: Running"

func _on_ar_session_failed(error: String):
	print("AR session failed: ", error)
	if status_label:
		status_label.text = "AR Session: Failed - " + error

func _on_tracking_state_changed(state: String):
	print("Tracking state changed: ", state)
	if tracking_label:
		tracking_label.text = "Tracking: " + state

func _on_camera_permission_granted():
	print("Camera permission granted")
	if status_label:
		status_label.text = "Camera Permission: Granted"

func _on_camera_permission_denied():
	print("Camera permission denied")
	if status_label:
		status_label.text = "Camera Permission: Denied"

func _check_ar_availability():
	# Verifica se AR è disponibile sulla piattaforma
	if OS.get_name() == "Android":
		is_ar_available = _check_android_ar()
	elif OS.get_name() == "iOS":
		is_ar_available = _check_ios_ar()
	else:
		print("AR not supported on platform: ", OS.get_name())
		is_ar_available = false
	
	if is_ar_available:
		print("AR is available on this device")
	else:
		print("AR is not available on this device")

func _check_android_ar() -> bool:
	# Placeholder per verifica ARCore su Android
	# In produzione, usare plugin Godot ARCore
	print("Checking Android ARCore availability...")
	return true  # Assume disponibile per ora

func _check_ios_ar() -> bool:
	# Placeholder per verifica ARKit su iOS
	# In produzione, usare plugin Godot ARKit
	print("Checking iOS ARKit availability...")
	return true  # Assume disponibile per ora

func start_ar_session():
	if not is_ar_available:
		ar_session_failed.emit("AR not available on this device")
		return
	
	if is_ar_running:
		print("AR session already running")
		return
	
	print("Starting AR session...")
	_request_camera_permission()

func _request_camera_permission():
	# Richiesta permesso fotocamera
	print("Requesting camera permission...")
	
	# Placeholder per richiesta permesso
	# In produzione, usare plugin specifici piattaforma per permessi
	# Android: Godot's permission system
	# iOS: Info.plist configuration
	
	# Simula concessione permesso per ora
	camera_permission_granted.emit()
	_initialize_ar_session()

func _initialize_ar_session():
	print("Initializing AR session...")
	is_ar_running = true
	tracking_state = "initializing"
	ar_session_started.emit()
	tracking_state_changed.emit(tracking_state)

func stop_ar_session():
	if not is_ar_running:
		print("AR session not running")
		return
	
	print("Stopping AR session...")
	is_ar_running = false
	tracking_state = "not_tracking"
	tracking_state_changed.emit(tracking_state)

func set_tracking_state(state: String):
	tracking_state = state
	tracking_state_changed.emit(state)
	print("AR tracking state: ", state)

func get_tracking_state() -> String:
	return tracking_state

func is_session_active() -> bool:
	return is_ar_running

func get_supported_features() -> Array:
	var features = []
	
	if OS.get_name() == "Android":
		features = ["plane_detection", "image_tracking", "depth_sensing"]
	elif OS.get_name() == "iOS":
		features = ["plane_detection", "image_tracking", "face_tracking", "lidar"]
	else:
		features = []
	
	return features
