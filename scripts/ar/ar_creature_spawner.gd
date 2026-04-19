extends Node3D

signal creature_spawned_in_ar(creature_id: String, ar_node: Node3D)
signal transition_to_ar_complete

var ar_creatures: Dictionary = {}
var max_ar_creatures: int = 5
var creature_scale: float = 1.0
var is_ar_mode: bool = false

func _ready():
	print("AR Creature Spawner initialized")

func spawn_creature_in_ar(creature_id: String, creature_type: String, surface_position: Vector3):
	if not is_ar_mode or ar_creatures.size() >= max_ar_creatures:
		return
	
	var creature_node = MeshInstance3D.new()
	creature_node.name = "ARCreature_" + creature_type
	creature_node.position = surface_position
	creature_node.scale = Vector3(creature_scale, creature_scale, creature_scale)
	
	var mesh = ArrayMesh.new()
	var vertices = PackedVector3Array([
		Vector3(0, 1, 0), Vector3(-0.5, 0, -0.5), 
		Vector3(0.5, 0, -0.5), Vector3(0.5, 0, 0.5)
	])
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	creature_node.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_color(creature_type)
	creature_node.material_override = material
	
	ar_creatures[creature_id] = creature_node
	add_child(creature_node)
	creature_spawned_in_ar.emit(creature_id, creature_node)

func _get_color(type: String) -> Color:
	if type == "dragon": return Color(1, 0.3, 0.3)
	if type == "warrior": return Color(0.3, 0.6, 1)
	if type == "water_spirit": return Color(0.2, 0.8, 0.8)
	return Color(1, 1, 1)

func despawn_creature(creature_id: String):
	if ar_creatures.has(creature_id):
		ar_creatures[creature_id].queue_free()
		ar_creatures.erase(creature_id)

func transition_to_ar():
	is_ar_mode = true
	transition_to_ar_complete.emit()

func transition_to_map():
	is_ar_mode = false
	clear_all_creatures()

func clear_all_creatures():
	for id in ar_creatures.keys():
		despawn_creature(id)

func set_creature_scale(scale: float):
	creature_scale = scale
