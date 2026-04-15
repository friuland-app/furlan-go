extends Control

@onready var start_button = $StartButton
@onready var settings_button = $SettingsButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_start_pressed():
	print("Inizia avventura!")
	# TODO: Caricare scena mappa

func _on_settings_pressed():
	print("Apri impostazioni")
	# TODO: Caricare scena impostazioni
