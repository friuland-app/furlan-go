extends Node3D

# Surface Detection Manager - gestisce rilevamento superfici in AR
signal surface_detected(surface_id: String, surface_type: String)
signal surface_lost(surface_id: String)
signal no_surfaces_available

var detected_surfaces: Dictionary = {}  # surface_id → dati superficie
var horizontal_detection_enabled: bool = true
var vertical_detection_enabled: bool = false
var detection_interval: float = 0.5  # Secondi
var max_surfaces: int = 10
var surface_meshes: Dictionary = {}  # surface_id → mesh node

var detection_timer: Timer
var xr_interface: XRInterface

func _ready():
	print("Surface Detection Manager initialized")
	_setup_detection_timer()
	_check_xr_interface()
	_enable_plane_detection()

func _setup_detection_timer():
	detection_timer = Timer.new()
	detection_timer.wait_time = detection_interval
	detection_timer.autostart = true
	detection_timer.timeout.connect(_on_detection_tick)
	add_child(detection_timer)

func _check_xr_interface():
	# Verifica interfaccia XR disponibile
	xr_interface = XRServer.find_interface("OpenXR")
	if not xr_interface:
		xr_interface = XRServer.find_interface("ARCore")
	
	if xr_interface:
		print("XR Interface found: ", xr_interface.get_name())
	else:
		print("No XR Interface found - surface detection may not work")

func _enable_plane_detection():
	if not xr_interface:
		print("Cannot enable plane detection - no XR interface")
		return
	
	# Abilita rilevamento piani
	xr_interface.set_plane_detection_enabled(horizontal_detection_enabled)
	print("Plane detection enabled: ", horizontal_detection_enabled)

func _on_detection_tick():
	# Esegue ciclo di rilevamento superfici
	if xr_interface and xr_interface.is_plane_detection_enabled():
		_detect_surfaces()
	else:
		_check_surfaces_available()

func _detect_surfaces():
	# Placeholder per rilevamento piani XR
	# In Godot 4.x, questo richiede integrazione con XRAnchor3D e XRPlane3D
	
	# Simula rilevamento superfici per demo
	_simulate_surface_detection()

func _simulate_surface_detection():
	# Simula rilevamento di superfici per testing
	# In produzione, usare XRAnchor3D e XRPlane3D reali
	
	if detected_surfaces.size() < max_surfaces and randf() < 0.3:
		var surface_id = "surface_" + str(randi())
		var surface_type = "horizontal" if randf() < 0.8 else "vertical"
		
		var surface_data = {
			"id": surface_id,
			"type": surface_type,
			"position": Vector3(randf_range(-2, 2), randf_range(-1, 1), randf_range(-2, 2)),
			"normal": Vector3.UP if surface_type == "horizontal" else Vector3.FORWARD,
			"timestamp": Time.get_unix_time_from_system()
		}
		
		detected_surfaces[surface_id] = surface_data
		_create_surface_mesh(surface_id, surface_data)
		surface_detected.emit(surface_id, surface_type)
		print("Surface detected: ", surface_id, " type: ", surface_type)

func _create_surface_mesh(surface_id: String, surface_data: Dictionary):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "SurfaceMesh_" + surface_id
	
	# Crea mesh semplice per visualizzazione
	var mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	
	# Crea quadrato 2x2 metri
	var size = 2.0
	var half_size = size / 2.0
	
	vertices.append(Vector3(-half_size, 0, -half_size))
	vertices.append(Vector3(half_size, 0, -half_size))
	vertices.append(Vector3(half_size, 0, half_size))
	vertices.append(Vector3(-half_size, 0, half_size))
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_FAN, arrays)
	mesh_instance.mesh = mesh
	
	# Configura materiale semitrasparente
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.5, 1.0, 0.5, 0.3)  # Verde semitrasparente
	material.cull_mode = BaseMaterial3D.CULL_BACK
	mesh_instance.material_override = material
	
	# Posiziona mesh
	mesh_instance.position = surface_data.position
	
	if surface_data.type == "vertical":
		mesh_instance.rotation_degrees = Vector3(90, 0, 0)
	
	add_child(mesh_instance)
	surface_meshes[surface_id] = mesh_instance

func remove_surface(surface_id: String):
	if detected_surfaces.has(surface_id):
		detected_surfaces.erase(surface_id)
		surface_lost.emit(surface_id)
		print("Surface removed: ", surface_id)
	
	if surface_meshes.has(surface_id):
		var mesh = surface_meshes[surface_id]
		mesh.queue_free()
		surface_meshes.erase(surface_id)

func clear_all_surfaces():
	var surface_ids = detected_surfaces.keys()
	for surface_id in surface_ids:
		remove_surface(surface_id)

func _check_surfaces_available():
	if detected_surfaces.size() == 0:
		no_surfaces_available.emit()
		print("No surfaces available")

func set_horizontal_detection(enabled: bool):
	horizontal_detection_enabled = enabled
	if xr_interface:
		xr_interface.set_plane_detection_enabled(horizontal_detection_enabled)
	print("Horizontal detection: ", enabled)

func set_vertical_detection(enabled: bool):
	vertical_detection_enabled = enabled
	print("Vertical detection: ", enabled)

func set_detection_interval(interval: float):
	detection_interval = interval
	if detection_timer:
		detection_timer.wait_time = interval
	print("Detection interval: ", interval, " seconds")

func set_max_surfaces(max: int):
	max_surfaces = max
	print("Max surfaces: ", max)

func get_surface_count() -> int:
	return detected_surfaces.size()

func get_surface_data(surface_id: String) -> Dictionary:
	if detected_surfaces.has(surface_id):
		return detected_surfaces[surface_id]
	return {}

func get_all_surfaces() -> Dictionary:
	return detected_surfaces

func is_surface_available() -> bool:
	return detected_surfaces.size() > 0

func optimize_detection_speed():
	# Ottimizza velocità rilevamento riducendo intervallo
	set_detection_interval(0.3)
	print("Detection speed optimized")
