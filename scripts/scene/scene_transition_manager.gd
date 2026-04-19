extends Node

# Scene Transition Manager - gestisce transizioni tra mappa e AR
signal transition_started(to_scene: String)
signal transition_completed(to_scene: String)
signal creature_data_transferred(creature_data: Dictionary)

var current_scene: String = "map"
var transition_creature_data: Dictionary = {}
var is_transitioning: bool = false

func _ready():
	print("Scene Transition Manager initialized")

func transition_to_ar(creature_id: String, creature_data: Dictionary):
	if is_transitioning:
		print("Already transitioning")
		return
	
	is_transitioning = true
	transition_creature_data = creature_data
	
	print("Transitioning to AR for creature: ", creature_id)
	transition_started.emit("ar")
	
	# Salva dati creatura per passaggio
	_creature_data_transferred.emit(creature_data)
	
	# Esegue transizione
	await _play_transition_animation()
	
	# Cambia scena
	current_scene = "ar"
	get_tree().change_scene_to_file("res://scenes/ar/ar_scene.tscn")
	
	transition_completed.emit("ar")

func transition_to_map(result: Dictionary):
	if is_transitioning:
		print("Already transitioning")
		return
	
	is_transitioning = true
	
	print("Transitioning to map with result: ", result)
	transition_started.emit("map")
	
	# Salva risultato su Firebase
	_save_capture_result(result)
	
	# Esegue transizione
	await _play_transition_animation()
	
	# Cambia scena
	current_scene = "map"
	get_tree().change_scene_to_file("res://scenes/map/map_scene.tscn")
	
	transition_completed.emit("map")

func _play_transition_animation():
	print("Playing transition animation")
	var tween = create_tween()
	tween.tween_property(get_viewport(), "modulate:a", 0.0, 0.5)
	await tween.finished
	tween.tween_property(get_viewport(), "modulate:a", 1.0, 0.5)
	await tween.finished

func _save_capture_result(result: Dictionary):
	print("Saving capture result to Firebase: ", result)
	# Placeholder per salvataggio Firebase
	# In produzione, usare FirebaseManager

func get_creature_data() -> Dictionary:
	return transition_creature_data

func set_creature_data(data: Dictionary):
	transition_creature_data = data

func is_in_ar_mode() -> bool:
	return current_scene == "ar"

func is_in_map_mode() -> bool:
	return current_scene == "map"
