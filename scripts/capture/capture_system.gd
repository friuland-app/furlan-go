extends Node

# Capture System - gestisce il sistema di cattura delle creature
signal capture_attempt(creature_id: String, trap_type: String)
signal capture_success(creature_id: String)
signal capture_failed(creature_id: String)

enum TrapType {
	COMMON,
	RARE,
	SPECIAL
}

enum CreatureRarity {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

var capture_rate: float = 0.5

func _ready():
	print("Capture System initialized")

func attempt_capture(creature_id: String, creature_data: Dictionary, trap_type: TrapType, remaining_hp: float, max_hp: float):
	print("Attempting capture: ", creature_id, " with trap: ", trap_type)
	capture_attempt.emit(creature_id, str(trap_type))
	
	var capture_chance = calculate_capture_chance(creature_data, trap_type, remaining_hp, max_hp)
	var roll = randf()
	
	print("Capture chance: ", capture_chance, " Roll: ", roll)
	
	if roll <= capture_chance:
		capture_success.emit(creature_id)
		_save_captured_creature(creature_id, creature_data)
	else:
		capture_failed.emit(creature_id)

func calculate_capture_chance(creature_data: Dictionary, trap_type: TrapType, remaining_hp: float, max_hp: float) -> float:
	var base_chance = 0.3
	
	# HP remaining bonus
	var hp_ratio = remaining_hp / max_hp
	var hp_bonus = (1.0 - hp_ratio) * 0.3
	
	# Trap type bonus
	var trap_bonus = 0.0
	match trap_type:
		TrapType.COMMON:
			trap_bonus = 0.0
		TrapType.RARE:
			trap_bonus = 0.15
		TrapType.SPECIAL:
			trap_bonus = 0.3
	
	# Rarity penalty
	var rarity_penalty = 0.0
	var rarity = creature_data.get("rarity", "Comune")
	match rarity:
		"Comune":
			rarity_penalty = 0.0
		"Raro":
			rarity_penalty = 0.1
		"Epico":
			rarity_penalty = 0.2
		"Leggendario":
			rarity_penalty = 0.3
	
	# Contextual bonuses (placeholder)
	var contextual_bonus = get_contextual_bonus()
	
	var total_chance = base_chance + hp_bonus + trap_bonus - rarity_penalty + contextual_bonus
	return clamp(total_chance, 0.05, 0.95)

func get_contextual_bonus() -> float:
	var bonus = 0.0
	
	# Time bonus (night time)
	var hour = Time.get_datetime_dict_from_system().hour
	if hour >= 20 or hour < 6:
		bonus += 0.1
	
	# Weather bonus (placeholder)
	# Zone bonus (placeholder)
	
	return bonus

func _save_captured_creature(creature_id: String, creature_data: Dictionary):
	print("Saving captured creature: ", creature_id)
	# Placeholder per salvataggio Firebase
	# In produzione, usare FirebaseManager

func play_trap_animation(trap_type: TrapType):
	print("Playing trap animation for: ", trap_type)

func show_capture_result(success: bool):
	print("Capture result: ", "Success" if success else "Failed")
