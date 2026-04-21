extends Node

signal xp_gained(amount: int)
signal level_up(new_level: int)
signal feature_unlocked(feature: String)
signal title_unlocked(title: String)
signal badge_unlocked(badge: String)

var player_level: int = 1
var player_xp: int = 0
var level_thresholds: Array = []
var unlocked_features: Array = []
var titles: Array = []
var badges: Array = []
var player_name: String = "Player"

func _ready():
	_generate_level_thresholds()

func _generate_level_thresholds():
	var xp = 0
	for i in range(1, 41):
		level_thresholds.append(xp)
		xp += i * 500

func add_xp(amount: int):
	player_xp += amount
	xp_gained.emit(amount)
	_check_level_up()

func _check_level_up():
	while player_level < 40 and player_xp >= level_thresholds[player_level]:
		player_level += 1
		_unlock_features(player_level)
		level_up.emit(player_level)

func _unlock_features(level: int):
	if level >= 5 and "rare_traps" not in unlocked_features:
		unlocked_features.append("rare_traps")
		feature_unlocked.emit("rare_traps")
	if level >= 10 and "special_traps" not in unlocked_features:
		unlocked_features.append("special_traps")
		feature_unlocked.emit("special_traps")
	if level >= 20 and "pvp_battle" not in unlocked_features:
		unlocked_features.append("pvp_battle")
		feature_unlocked.emit("pvp_battle")

func unlock_title(title: String):
	if title not in titles:
		titles.append(title)
		title_unlocked.emit(title)

func unlock_badge(badge: String):
	if badge not in badges:
		badges.append(badge)
		badge_unlocked.emit(badge)

func get_player_profile() -> Dictionary:
	return {
		"name": player_name,
		"level": player_level,
		"xp": player_xp,
		"titles": titles,
		"badges": badges
	}

func add_xp_capture():
	add_xp(100 + player_level * 10)

func add_xp_battle(won: bool):
	add_xp(50 if won else 25)

func add_xp_poi():
	add_xp(75)

func add_xp_mission():
	add_xp(200)
