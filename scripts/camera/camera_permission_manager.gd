extends Node

signal permission_granted
signal permission_denied

var camera_permission_granted: bool = false

func _ready():
	_request_camera_permission()

func _request_camera_permission():
	if OS.get_name() == "Android":
		await get_tree().create_timer(0.5).timeout
	_permission_granted()
	elif OS.get_name() == "iOS":
		await get_tree().create_timer(0.5).timeout
		_permission_granted()

func _permission_granted():
	camera_permission_granted = true
	permission_granted.emit()

func start_camera():
	print("Camera started")

func stop_camera():
	print("Camera stopped")

func handle_interruption():
	print("Camera interrupted")

func optimize_video_quality():
	print("Video quality optimized")

func handle_orientation_change():
	print("Orientation changed")
