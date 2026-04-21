extends Node

# Battle System - gestisce il sistema di combattimento
signal battle_started
signal turn_started(creature_id: String)
signal attack_executed(attacker: String, damage: int)
signal battle_ended(winner: String)

enum CreatureType {
	WATER,
	EARTH,
	FIRE,
	AIR,
	LEGEND
}

enum BattleState {
	PLAYER_TURN,
	CREATURE_TURN,
	BATTLE_ENDED
}

var current_state: BattleState = BattleState.PLAYER_TURN
var player_hp: int = 100
var creature_hp: int = 100
var max_player_hp: int = 100
var max_creature_hp: int = 100
var current_creature: Dictionary = {}

func _ready():
	print("Battle System initialized")

func start_battle(creature_data: Dictionary):
	print("Starting battle with creature: ", creature_data.get("id", "unknown"))
	current_creature = creature_data
	creature_hp = creature_data.get("stats", {}).get("hp", 100)
	max_creature_hp = creature_hp
	player_hp = max_player_hp
	
	battle_started.emit()
	current_state = BattleState.PLAYER_TURN
	turn_started.emit("player")

func player_attack(move_type: String):
	if current_state != BattleState.PLAYER_TURN:
		return
	
	print("Player attacks with: ", move_type)
	var damage = calculate_damage("player", move_type)
	creature_hp -= damage
	
	attack_executed.emit("player", damage)
	
	if creature_hp <= 0:
		_end_battle("player")
	else:
		current_state = BattleState.CREATURE_TURN
		await get_tree().create_timer(1.0).timeout
		_creature_turn()

func _creature_turn():
	print("Creature's turn")
	var damage = calculate_damage("creature", "basic_attack")
	player_hp -= damage
	
	attack_executed.emit("creature", damage)
	
	if player_hp <= 0:
		_end_battle("creature")
	else:
		current_state = BattleState.PLAYER_TURN
		turn_started.emit("player")

func calculate_damage(attacker: String, move_type: String) -> int:
	var base_damage = 10
	var type_bonus = get_type_effectiveness_bonus(attacker)
	return base_damage + type_bonus

func get_type_effectiveness_bonus(attacker: String) -> int:
	# Water > Fire > Earth > Air > Water
	var creature_type = current_creature.get("type", "Water")
	
	if attacker == "player":
		# Player uses Water type (assumed)
		if creature_type == "Fuoco":
			return 10
		elif creature_type == "Acqua":
			return -5
	
	return 0

func _end_battle(winner: String):
	print("Battle ended. Winner: ", winner)
	current_state = BattleState.BATTLE_ENDED
	battle_ended.emit(winner)

func get_battle_state() -> BattleState:
	return current_state

func get_hp_status() -> Dictionary:
	return {
		"player_hp": player_hp,
		"max_player_hp": max_player_hp,
		"creature_hp": creature_hp,
		"max_creature_hp": max_creature_hp
	}
