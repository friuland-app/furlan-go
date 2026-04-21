extends Node

# Inventory Manager - gestisce l'inventario del giocatore
signal creature_added(creature_id: String)
signal creature_removed(creature_id: String)
signal item_added(item_id: String)
signal item_used(item_id: String)
signal inventory_updated

var active_squad: Array = []  # Max 6 creature
var creature_storage: Array = []  # Creature in deposito
var items: Dictionary = {}  # item_id → quantity
var achievements: Array = []

var max_squad_size: int = 6

func _ready():
	print("Inventory Manager initialized")

func add_creature(creature_id: String, creature_data: Dictionary):
	if active_squad.size() < max_squad_size:
		active_squad.append(creature_id)
		creature_added.emit(creature_id)
		print("Creature added to active squad: ", creature_id)
	else:
		creature_storage.append(creature_id)
		creature_added.emit(creature_id)
		print("Creature added to storage: ", creature_id)
	
	inventory_updated.emit()

func remove_creature(creature_id: String):
	if creature_id in active_squad:
		active_squad.erase(creature_id)
	elif creature_id in creature_storage:
		creature_storage.erase(creature_id)
	
	creature_removed.emit(creature_id)
	inventory_updated.emit()
	print("Creature removed: ", creature_id)

func move_to_active_squad(creature_id: String):
	if active_squad.size() >= max_squad_size:
		print("Active squad is full")
		return
	
	if creature_id in creature_storage:
		creature_storage.erase(creature_id)
		active_squad.append(creature_id)
		inventory_updated.emit()
		print("Creature moved to active squad: ", creature_id)

func move_to_storage(creature_id: String):
	if creature_id in active_squad:
		active_squad.erase(creature_id)
		creature_storage.append(creature_id)
		inventory_updated.emit()
		print("Creature moved to storage: ", creature_id)

func add_item(item_id: String, quantity: int = 1):
	if items.has(item_id):
		items[item_id] += quantity
	else:
		items[item_id] = quantity
	
	item_added.emit(item_id)
	inventory_updated.emit()
	print("Item added: ", item_id, " quantity: ", quantity)

func use_item(item_id: String):
	if not items.has(item_id) or items[item_id] <= 0:
		print("Item not available: ", item_id)
		return
	
	items[item_id] -= 1
	if items[item_id] <= 0:
		items.erase(item_id)
	
	item_used.emit(item_id)
	inventory_updated.emit()
	print("Item used: ", item_id)

func add_achievement(achievement_id: String):
	if not achievement_id in achievements:
		achievements.append(achievement_id)
		print("Achievement unlocked: ", achievement_id)

func get_active_squad() -> Array:
	return active_squad

func get_creature_storage() -> Array:
	return creature_storage

func get_items() -> Dictionary:
	return items

func get_achievements() -> Array:
	return achievements

func get_total_creatures() -> int:
	return active_squad.size() + creature_storage.size()

func save_inventory():
	print("Saving inventory to Firebase")
	# Placeholder per salvataggio Firebase

func sync_with_firebase():
	print("Syncing inventory with Firebase")
	# Placeholder per sincronizzazione real-time
