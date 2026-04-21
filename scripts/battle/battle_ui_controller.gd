extends Control

# Battle UI Controller - gestisce l'interfaccia di combattimento
var player_hp_bar: ProgressBar
var creature_hp_bar: ProgressBar
var battle_log: Label
var attack_buttons: Array = []

func _ready():
	print("Battle UI Controller initialized")
	_setup_ui()

func _setup_ui():
	# Setup UI elements
	player_hp_bar = get_node_or_null("PlayerHPBar")
	creature_hp_bar = get_node_or_null("CreatureHPBar")
	battle_log = get_node_or_null("BattleLog")
	
	# Setup attack buttons
	attack_buttons = [
		get_node_or_null("AttackButton"),
		get_node_or_null("SpecialButton"),
		get_node_or_null("CaptureButton")
	]
	
	# Connect BattleSystem signals
	BattleSystem.battle_started.connect(_on_battle_started)
	BattleSystem.turn_started.connect(_on_turn_started)
	BattleSystem.attack_executed.connect(_on_attack_executed)
	BattleSystem.battle_ended.connect(_on_battle_ended)

func _on_battle_started():
	print("Battle started in UI")
	_update_hp_bars()
	battle_log.text = "Battle started!"

func _on_turn_started(creature_id: String):
	print("Turn started: ", creature_id)
	if creature_id == "player":
		_enable_attack_buttons()
	else:
		_disable_attack_buttons()
		battle_log.text = "Creature's turn..."

func _on_attack_executed(attacker: String, damage: int):
	print("Attack executed: ", attacker, " damage: ", damage)
	_update_hp_bars()
	battle_log.text = attacker + " dealt " + str(damage) + " damage!"

func _on_battle_ended(winner: String):
	print("Battle ended: ", winner)
	battle_log.text = winner + " won the battle!"
	_disable_attack_buttons()

func _update_hp_bars():
	var hp_status = BattleSystem.get_hp_status()
	if player_hp_bar:
		player_hp_bar.value = (hp_status.player_hp / hp_status.max_player_hp) * 100
	if creature_hp_bar:
		creature_hp_bar.value = (hp_status.creature_hp / hp_status.max_creature_hp) * 100

func _enable_attack_buttons():
	for button in attack_buttons:
		if button:
			button.disabled = false

func _disable_attack_buttons():
	for button in attack_buttons:
		if button:
			button.disabled = true

func on_attack_button_pressed():
	print("Attack button pressed")
	BattleSystem.player_attack("attack")

func on_special_button_pressed():
	print("Special button pressed")
	BattleSystem.player_attack("special")

func on_capture_button_pressed():
	print("Capture button pressed")
	BattleSystem.player_attack("capture")
