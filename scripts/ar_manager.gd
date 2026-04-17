extends Node

# AR Manager singleton per gestire ARCore/ARKit
signal ar_session_started
signal ar_session_failed(error: String)
signal plane_detected(position: Vector3)
signal anchor_added(anchor_id: String)

var ar_interface: ARInterface
var is_ar_supported: bool = false
var is_ar_session_active: bool = false

func _ready():
	print("AR Manager initialized")
	check_ar_support()

func check_ar_support():
	# TODO: Check if AR is supported on device
	# This will be implemented when ARCore plugin is fully configured
	print("Checking AR support...")
	
	# Placeholder for AR support check
	is_ar_supported = true
	print("AR support: ", is_ar_supported)

func start_ar_session():
	if not is_ar_supported:
		ar_session_failed.emit("AR not supported on this device")
		return
	
	print("Starting AR session...")
	# TODO: Initialize ARCore session
	is_ar_session_active = true
	ar_session_started.emit()

func stop_ar_session():
	print("Stopping AR session...")
	is_ar_session_active = false
	# TODO: Stop ARCore session

func place_anchor(position: Vector3):
	# TODO: Place AR anchor at position
	print("Placing anchor at: ", position)
