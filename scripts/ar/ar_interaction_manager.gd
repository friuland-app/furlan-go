extends Control

# AR Interaction Manager - gestisce interazione touch/swipe con creature AR
signal creature_selected(creature_id: String)
signal trap_launched(target_position: Vector3)
signal interaction_started
signal interaction_ended

var selected_creature: String = ""
var is_interacting: bool = false
var swipe_start_position: Vector2
var swipe_end_position: Vector2
var min_swipe_distance: float = 50.0  # Pixel

# UI elements
@onready var crosshair = $Crosshair
@onready var feedback_label = $FeedbackLabel

func _ready():
	print("AR Interaction Manager initialized")
	_setup_crosshair()

func _setup_crosshair():
	if not crosshair:
		crosshair = ColorRect.new()
		crosshair.name = "Crosshair"
		crosshair.size = Vector2(20, 20)
		crosshair.position = Vector2(get_viewport_rect().size.x / 2 - 10, get_viewport_rect().size.y / 2 - 10)
		crosshair.color = Color(1, 0, 0, 0.5)
		add_child(crosshair)

func _input(event):
	if not is_interacting:
		return
	
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event):
	if event.pressed:
		swipe_start_position = event.position
		interaction_started.emit()
	else:
		swipe_end_position = event.position
		_check_swipe()
		interaction_ended.emit()

func _handle_drag(event):
	swipe_end_position = event.position

func _check_swipe():
	var swipe_vector = swipe_end_position - swipe_start_position
	var swipe_distance = swipe_vector.length()
	
	if swipe_distance >= min_swipe_distance:
		_launch_trap(swipe_vector)
	else:
		_select_creature_at_position(swipe_start_position)

func _select_creature_at_position(screen_pos: Vector2):
	print("Selecting creature at: ", screen_pos)
	# Placeholder per raycast AR
	selected_creature = "selected_creature"
	creature_selected.emit(selected_creature)
	_show_feedback("Creature selected")

func _launch_trap(swipe_vector: Vector2):
	print("Launching trap with swipe: ", swipe_vector)
	var direction = swipe_vector.normalized()
	var target_position = Vector3(direction.x * 2, 0, direction.y * 2)
	trap_launched.emit(target_position)
	_show_feedback("Trap launched")
	_play_launch_sound()

func _show_feedback(text: String):
	if feedback_label:
		feedback_label.text = text
		feedback_label.visible = true
		await get_tree().create_timer(1.0).timeout
		feedback_label.visible = false

func _play_launch_sound():
	print("Playing launch sound")
	# Placeholder per suono

func start_interaction():
	is_interacting = true
	if crosshair:
		crosshair.visible = true

func stop_interaction():
	is_interacting = false
	if crosshair:
		crosshair.visible = false

func set_crosshair_color(color: Color):
	if crosshair:
		crosshair.color = color
