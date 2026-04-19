extends Node

# AR Optimization Manager - gestisce ottimizzazioni AR
signal fps_limited(fps: int)
signal lod_changed(level: int)
signal memory_warning
signal temperature_warning

var target_fps: int = 60
var current_lod_level: int = 0  # 0: High, 1: Medium, 2: Low
var is_battery_saver: bool = false
var device_temperature: float = 0.0

func _ready():
	print("AR Optimization Manager initialized")
	_apply_fps_limit()
	_monitor_memory()

func set_fps_limit(fps: int):
	target_fps = fps
	Engine.max_fps = target_fps
	fps_limited.emit(fps)
	print("FPS limited to: ", fps)

func enable_battery_saver():
	is_battery_saver = true
	set_fps_limit(30)
	set_lod_level(2)
	print("Battery saver enabled")

func disable_battery_saver():
	is_battery_saver = false
	set_fps_limit(60)
	set_lod_level(0)
	print("Battery saver disabled")

func set_lod_level(level: int):
	current_lod_level = clamp(level, 0, 2)
	lod_changed.emit(current_lod_level)
	print("LOD level: ", current_lod_level)

func get_lod_level() -> int:
	return current_lod_level

func _monitor_memory():
	print("Monitoring memory")
	var monitor_timer = Timer.new()
	monitor_timer.wait_time = 5.0
	monitor_timer.timeout.connect(_check_memory_usage)
	add_child(monitor_timer)
	monitor_timer.autostart = true

func _check_memory_usage():
	var memory_usage = OS.get_static_mem_usage_by_type(OS.MEMORY_VIDEO)
	print("Video memory: ", memory_usage / 1024 / 1024, " MB")
	
	if memory_usage > 500 * 1024 * 1024:  # 500 MB
		memory_warning.emit()
		set_lod_level(2)
		print("Memory warning - reducing LOD")

func monitor_temperature():
	print("Monitoring device temperature")
	var temp_timer = Timer.new()
	temp_timer.wait_time = 10.0
	temp_timer.timeout.connect(_check_temperature)
	add_child(temp_timer)
	temp_timer.autostart = true

func _check_temperature():
	# Placeholder per temperatura reale
	device_temperature = randf_range(30, 45)
	print("Device temperature: ", device_temperature, "°C")
	
	if device_temperature > 40:
		temperature_warning.emit()
		enable_battery_saver()
		print("Temperature warning - enabling battery saver")

func get_performance_stats() -> Dictionary:
	return {
		"fps": Engine.get_frames_per_second(),
		"lod_level": current_lod_level,
		"battery_saver": is_battery_saver,
		"temperature": device_temperature
	}
