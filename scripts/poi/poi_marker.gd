extends Node2D

# POI Marker - visualizza i Punti di Interest sulla mappa
signal marker_clicked(poi_id: String)

var poi_id: String = ""
var poi_data: Dictionary = {}
var is_interactable: bool = false
var is_on_cooldown: bool = false

@onready var marker_sprite = $MarkerSprite
@onready var cooldown_indicator = $CooldownIndicator
@onready var interaction_ring = $InteractionRing
@onready var poi_label = $POILabel
@onready var cooldown_label = $CooldownLabel

var icon_colors: Dictionary = {
	"church": Color(0.8, 0.4, 0.4),
	"castle": Color(0.6, 0.4, 0.8),
	"bridge": Color(0.4, 0.6, 0.8),
	"temple": Color(0.8, 0.6, 0.4),
	"nature": Color(0.4, 0.8, 0.4),
	"museum": Color(0.8, 0.8, 0.4),
	"square": Color(0.6, 0.6, 0.6)
}

func _ready():
	if marker_sprite:
		marker_sprite.modulate = _get_icon_color()
	
	if cooldown_indicator:
		cooldown_indicator.visible = false
	
	if interaction_ring:
		interaction_ring.visible = false
	
	if poi_label:
		poi_label.text = poi_data.get("name", "Unknown")
		poi_label.visible = false
	
	if cooldown_label:
		cooldown_label.visible = false

func setup(poi_id_param: String, poi_data_param: Dictionary):
	poi_id = poi_id_param
	poi_data = poi_data_param
	
	if marker_sprite:
		marker_sprite.modulate = _get_icon_color()
	
	if poi_label:
		poi_label.text = poi_data.get("name", "Unknown")

func _get_icon_color() -> Color:
	var icon_type = poi_data.get("icon", "square")
	if icon_colors.has(icon_type):
		return icon_colors[icon_type]
	return Color(1.0, 1.0, 1.0)

func set_interactable(interactable: bool):
	is_interactable = interactible
	
	if interaction_ring:
		interaction_ring.visible = interactable
	
	if poi_label:
		poi_label.visible = interactable

func set_on_cooldown(cooldown: bool, remaining_seconds: int = 0):
	is_on_cooldown = cooldown
	
	if cooldown_indicator:
		cooldown_indicator.visible = cooldown
	
	if cooldown_label:
		cooldown_label.visible = cooldown
		if cooldown and remaining_seconds > 0:
			var minutes = remaining_seconds / 60
			var seconds = remaining_seconds % 60
			cooldown_label.text = str(minutes) + ":" + str(seconds).pad_zeros(2)
		else:
			cooldown_label.text = ""
	
	# Disabilita interazione se in cooldown
	if cooldown and is_interactable:
		set_interactable(false)

func update_cooldown_display(remaining_seconds: int):
	if cooldown_label and is_on_cooldown:
		var minutes = remaining_seconds / 60
		var seconds = remaining_seconds % 60
		cooldown_label.text = str(minutes) + ":" + str(seconds).pad_zeros(2)

func _on_marker_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		marker_clicked.emit(poi_id)
