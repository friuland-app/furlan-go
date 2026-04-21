extends Node

# Creature Progression System - gestisce XP, livelli ed evoluzione
signal xp_gained(creature_id: String, xp_amount: int)
signal level_up(creature_id: String, new_level: int)
signal evolution_triggered(creature_id: String, new_stage: int)

var creature_progress: Dictionary = {}  # creature_id → progress data
var level_thresholds: Array = []

func _ready():
	print("Creature Progression System initialized")
	_generate_level_thresholds()

func _generate_level_thresholds():
	# Genera soglie XP per livelli 1-50
	var xp = 0
	for i in range(1, 51):
		level_thresholds.append(xp)
		xp += i * 100  # XP aumenta progressivamente

func add_xp(creature_id: String, xp_amount: int):
	if not creature_progress.has(creature_id):
		_init_creature_progress(creature_id)
	
	var progress = creature_progress[creature_id]
	progress.xp += xp_amount
	progress.total_xp += xp_amount
	
	print("Creature ", creature_id, " gained ", xp_amount, " XP. Total: ", progress.xp)
	xp_gained.emit(creature_id, xp_amount)
	
	_check_level_up(creature_id)

func _check_level_up(creature_id: String):
	var progress = creature_progress[creature_id]
	var current_level = progress.level
	
	while current_level < 50 and progress.xp >= level_thresholds[current_level]:
		current_level += 1
	
	if current_level > progress.level:
		progress.level = current_level
		_update_stats_on_level_up(creature_id, current_level)
		level_up.emit(creature_id, current_level)
		print("Creature ", creature_id, " leveled up to ", current_level)
		
		_check_evolution(creature_id)

func _update_stats_on_level_up(creature_id: String, new_level: int):
	var progress = creature_progress[creature_id]
	var base_stats = progress.base_stats
	
	# Aggiorna statistiche: +5% per livello
	var multiplier = 1.0 + (new_level * 0.05)
	progress.current_stats = {
		"hp": int(base_stats.hp * multiplier),
		"attack": int(base_stats.attack * multiplier),
		"defense": int(base_stats.defense * multiplier),
		"speed": int(base_stats.speed * multiplier)
	}

func _check_evolution(creature_id: String):
	var progress = creature_progress[creature_id]
	var evolution_levels = [15, 30, 45]  # Livelli di evoluzione
	
	if progress.evolution_stage < 3:
		var required_level = evolution_levels[progress.evolution_stage]
		if progress.level >= required_level:
			progress.evolution_stage += 1
			evolution_triggered.emit(creature_id, progress.evolution_stage)
			_play_evolution_animation()
			print("Creature ", creature_id, " evolved to stage ", progress.evolution_stage)

func _play_evolution_animation():
	print("Playing evolution animation")
	# Placeholder per animazione evoluzione

func _init_creature_progress(creature_id: String):
	creature_progress[creature_id] = {
		"level": 1,
		"xp": 0,
		"total_xp": 0,
		"evolution_stage": 0,
		"base_stats": {
			"hp": 100,
			"attack": 50,
			"defense": 40,
			"speed": 30
		},
		"current_stats": {
			"hp": 100,
			"attack": 50,
			"defense": 40,
			"speed": 30
		}
	}

func get_creature_level(creature_id: String) -> int:
	if creature_progress.has(creature_id):
		return creature_progress[creature_id].level
	return 1

func get_creature_xp(creature_id: String) -> int:
	if creature_progress.has(creature_id):
		return creature_progress[creature_id].xp
	return 0

func get_creature_stats(creature_id: String) -> Dictionary:
	if creature_progress.has(creature_id):
		return creature_progress[creature_id].current_stats
	return {}

func get_evolution_stage(creature_id: String) -> int:
	if creature_progress.has(creature_id):
		return creature_progress[creature_id].evolution_stage
	return 0

func save_progress():
	print("Saving creature progression to Firebase")
	# Placeholder per salvataggio Firebase
