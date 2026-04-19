extends Control

# Loading Screen Controller - gestisce la schermata di caricamento
signal loading_complete
signal loading_progress(progress: float)

var loading_progress: float = 0.0
var loading_speed: float = 2.0  # Secondi per completare il caricamento
var is_loading: bool = false

# Riferimenti UI
@onready var title_label = $VBoxContainer/TitleLabel
@onready var loading_bar = $VBoxContainer/LoadingBar
@onready var loading_bar_fill = $VBoxContainer/LoadingBar/LoadingBarFill
@onready var status_label = $VBoxContainer/StatusLabel
@onready var background = $Background

func _ready():
	print("Loading Screen Controller initialized")
	_reset_loading()
	_start_loading()

func _process(delta):
	if is_loading:
		_update_loading(delta)

func _start_loading():
	is_loading = true
	loading_progress = 0.0
	_update_ui()

func _update_loading(delta):
	loading_progress += delta / loading_speed
	
	if loading_progress >= 1.0:
		loading_progress = 1.0
		is_loading = false
		_on_loading_complete()
	
	_update_ui()
	loading_progress.emit(loading_progress)

func _update_ui():
	if loading_bar_fill:
		loading_bar_fill.scale.x = loading_progress
	
	if status_label:
		if is_loading:
			var percent = int(loading_progress * 100)
			status_label.text = "Caricamento... " + str(percent) + "%"
		else:
			status_label.text = "Pronto!"

func _on_loading_complete():
	print("Loading complete!")
	loading_complete.emit()
	
	# Transizione alla scena principale dopo breve delay
	await get_tree().create_timer(0.5).timeout
	_transition_to_main_scene()

func _transition_to_main_scene():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _reset_loading():
	loading_progress = 0.0
	is_loading = false
	_update_ui()

func set_loading_speed(speed: float):
	loading_speed = speed
	print("Loading speed set to: ", loading_speed, " seconds")

func get_progress() -> float:
	return loading_progress

func is_complete() -> bool:
	return loading_progress >= 1.0
