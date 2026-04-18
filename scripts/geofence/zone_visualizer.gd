extends Node2D

# Zone Visualizer - visualizza le zone di gioco sulla mappa
var zone_indicators: Dictionary = {}  # zone_id → node

func _ready():
	print("Zone Visualizer initialized")
	_create_zone_indicators()

func _create_zone_indicators():
	var zones = GeofenceManager.get_all_zones()
	
	for zone_id in zones:
		var zone_data = zones[zone_id]
		_create_zone_indicator(zone_id, zone_data)

func _create_zone_indicator(zone_id: String, zone_data: Dictionary):
	# Crea indicatore visivo per la zona
	var zone_node = Node2D.new()
	zone_node.name = zone_id
	
	# Crea cerchio per la zona
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = _meters_to_pixels(zone_data.radius_meters)
	collision_shape.shape = circle_shape
	zone_node.add_child(collision_shape)
	
	# Crea ColorRect per visualizzazione
	var color_rect = ColorRect.new()
	color_rect.color = zone_data.color
	color_rect.size = Vector2(circle_shape.radius * 2, circle_shape.radius * 2)
	color_rect.position = Vector2(-circle_shape.radius, -circle_shape.radius)
	color_rect.z_index = -1  # Dietro la mappa
	zone_node.add_child(color_rect)
	
	# Posiziona la zona sulla mappa
	var map_position = _lat_lon_to_map_position(zone_data.center_lat, zone_data.center_lon)
	zone_node.position = map_position
	
	# Aggiungi label nome zona
	var label = Label.new()
	label.text = zone_data.name
	label.position = Vector2(-50, -circle_shape.radius - 25)
	label.z_index = 100
	zone_node.add_child(label)
	
	add_child(zone_node)
	zone_indicators[zone_id] = zone_node
	
	print("Created zone indicator: ", zone_data.name)

func _meters_to_pixels(meters: float) -> float:
	# Conversione approssimativa metri → pixel
	# Scala dipende dal zoom della mappa
	var map_scale = 1.0  # Aumentare per zoom maggiore
	return meters * map_scale * 0.01

func _lat_lon_to_map_position(lat: float, lon: float) -> Vector2:
	# Conversione lat/lon → posizione mappa
	var center_lat = MapManager.center_latitude
	var center_lon = MapManager.center_longitude
	
	var lat_offset = (lat - center_lat) * 111000.0
	var lon_offset = (lon - center_lon) * 111000.0 * cos(deg_to_rad(center_lat))
	
	var map_scale = 1.0
	return Vector2(640 + lat_offset * map_scale, 360 + lon_offset * map_scale)

func highlight_zone(zone_id: String, highlight: bool):
	if not zone_indicators.has(zone_id):
		return
	
	var zone_node = zone_indicators[zone_id]
	var color_rect = zone_node.get_child(1)  # ColorRect
	
	if highlight:
		color_rect.modulate = Color(1.5, 1.5, 1.5, 1.0)
	else:
		color_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)

func update_zone_position(zone_id: String, lat: float, lon: float):
	if not zone_indicators.has(zone_id):
		return
	
	var zone_node = zone_indicators[zone_id]
	zone_node.position = _lat_lon_to_map_position(lat, lon)

func remove_zone_indicator(zone_id: String):
	if not zone_indicators.has(zone_id):
		return
	
	var zone_node = zone_indicators[zone_id]
	zone_node.queue_free()
	zone_indicators.erase(zone_id)
