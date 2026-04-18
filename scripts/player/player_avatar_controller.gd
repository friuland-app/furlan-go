extends Node2D

# Player Avatar Controller - gestisce visualizzazione e movimento avatar sulla mappa
signal avatar_moving
signal avatar_stopped
signal avatar_position_changed(new_position: Vector2)

var current_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var movement_speed: float = 200.0  # Pixel al secondo
var rotation_speed: float = 5.0  # Gradi al frame
var last_position: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO

# Riferimenti ai nodi
@onready var avatar_sprite: Sprite2D = $AvatarSprite
@onready var direction_indicator: Node2D = $DirectionIndicator
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	print("Player Avatar Controller initialized")
	current_position = position
	last_position = position
	_setup_avatar()

func _setup_avatar():
	# Configura aspetto avatar
	if avatar_sprite:
		avatar_sprite.modulate = Color(1.0, 0.3, 0.3)  # Rosso per visibilità
	
	if direction_indicator:
		direction_indicator.visible = false  # Nascondi inizialmente

func _process(delta):
	_update_movement(delta)
	_update_rotation(delta)
	_update_animation()

func _update_movement(delta):
	if not is_moving:
		return
	
	# Interpola verso posizione target
	var direction = target_position - current_position
	var distance = direction.length()
	
	if distance < 5.0:  # Soglia per fermare movimento
		current_position = target_position
		is_moving = false
		position = current_position
		avatar_stopped.emit()
		return
	
	# Muovi verso target
	var move_distance = min(distance, movement_speed * delta)
	movement_direction = direction.normalized()
	current_position += movement_direction * move_distance
	position = current_position
	
	avatar_position_changed.emit(current_position)

func _update_rotation(delta):
	if not is_moving or movement_direction.length() < 0.1:
		return
	
	# Calcola rotazione target basata su direzione movimento
	var target_rotation = movement_direction.angle()
	
	# Interpola rotazione
	var current_rotation = rotation
	var rotation_diff = target_rotation - current_rotation
	
	# Normalizza differenza angolo tra -PI e PI
	while rotation_diff > PI:
		rotation_diff -= 2 * PI
	while rotation_diff < -PI:
		rotation_diff += 2 * PI
	
	# Applica rotazione graduale
	var rotation_step = rotation_speed * delta * 0.1
	if abs(rotation_diff) < rotation_step:
		rotation = target_rotation
	else:
		rotation += sign(rotation_diff) * rotation_step

func _update_animation():
	if is_moving:
		if animation_player and not animation_player.is_playing():
			animation_player.play("walk")
	else:
		if animation_player and animation_player.is_playing():
			animation_player.stop()

func set_target_position(new_position: Vector2):
	target_position = new_position
	last_position = current_position
	
	if not is_moving:
		is_moving = true
		avatar_moving.emit()

func set_avatar_color(color: Color):
	if avatar_sprite:
		avatar_sprite.modulate = color

func set_movement_speed(speed: float):
	movement_speed = speed

func set_rotation_speed(speed: float):
	rotation_speed = speed

func stop_movement():
	is_moving = false
	avatar_stopped.emit()

func get_movement_direction() -> Vector2:
	return movement_direction

func is_avatar_moving() -> bool:
	return is_moving

func update_from_gps(latitude: float, longitude: float):
	# Converti coordinate GPS in posizione mappa
	var map_position = _gps_to_map_position(latitude, longitude)
	set_target_position(map_position)

func _gps_to_map_position(lat: float, lon: float) -> Vector2:
	# Conversione semplice lat/lon → posizione mappa
	# In produzione, usare proiezione più accurata
	var center_lat = MapManager.center_latitude
	var center_lon = MapManager.center_longitude
	
	# Conversione approssimativa in pixel
	var lat_offset = (lat - center_lat) * 111000.0  # Metri per grado latitudine
	var lon_offset = (lon - center_lon) * 111000.0 * cos(deg_to_rad(center_lat))  # Metri per grado longitudine
	
	# Scala metri → pixel (scala mappa)
	var map_scale = 1.0  # Aumentare per zoom maggiore
	
	return Vector2(lat_offset * map_scale, lon_offset * map_scale)
