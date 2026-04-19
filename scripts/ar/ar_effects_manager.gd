extends Node3D

var particle_systems: Dictionary = {}
var dynamic_lights: Dictionary = {}

func _ready():
	print("AR Effects Manager initialized")

func play_spawn_particles(position: Vector3, color: Color = Color.WHITE):
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.amount = 50
	add_child(particles)
	
	await get_tree().create_timer(2.0).timeout
	particles.queue_free()

func play_materialization_effect(creature_node: Node3D):
	var tween = create_tween()
	tween.tween_property(creature_node, "scale", Vector3(1, 1, 1), 1.0).from(Vector3(0, 0, 0))

func add_dynamic_light(creature_id: String, position: Vector3, color: Color = Color.YELLOW):
	var light = OmniLight3D.new()
	light.position = position
	light.light_color = color
	light.light_energy = 2.0
	add_child(light)
	dynamic_lights[creature_id] = light

func add_shadow_caster(creature_node: Node3D):
	creature_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

func play_capture_success_effect(position: Vector3):
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.amount = 100
	add_child(particles)
	
	await get_tree().create_timer(2.0).timeout
	particles.queue_free()

func play_capture_fail_effect(position: Vector3):
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.amount = 50
	add_child(particles)
	
	await get_tree().create_timer(1.5).timeout
	particles.queue_free()
