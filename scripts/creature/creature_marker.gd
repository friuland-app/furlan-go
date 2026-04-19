extends Node2D

# Creature Marker - visualizza le creature sulla mappa
signal marker_clicked(creature_id: String)

var creature_id: String = ""
var creature_data: Dictionary = {}
var is_interactable: bool = false

@onready var marker_sprite = $MarkerSprite
@onready var interaction_ring = $InteractionRing
@onready var creature_label = $CreatureLabel

func _ready():
	if marker_sprite:
		marker_sprite.modulate = creature_data.get("marker_color", Color(1.0, 1.0, 1.0))
	
	if interaction_ring:
		interaction_ring.visible = false
	
	if creature_label:
		creature_label.text = creature_data.get("name", "Unknown")
		creature_label.visible = false

func setup(creature_id_param: String, creature_data_param: Dictionary):
	creature_id = creature_id_param
	creature_data = creature_data_param
	
	if marker_sprite:
		marker_sprite.modulate = creature_data.get("marker_color", Color(1.0, 1.0, 1.0))
	
	if creature_label:
		creature_label.text = creature_data.get("name", "Unknown")

func set_interactable(interactable: bool):
	is_interactable = interactible
	
	if interaction_ring:
		interaction_ring.visible = interactible
	
	if creature_label:
		creature_label.visible = interactible

func _on_marker_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		marker_clicked.emit(creature_id)
