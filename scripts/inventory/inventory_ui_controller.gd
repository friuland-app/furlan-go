extends Control

# Inventory UI Controller - gestisce l'interfaccia inventario
var creature_list: ItemList
var item_list: ItemList
var achievement_list: ItemList

func _ready():
	print("Inventory UI Controller initialized")
	_setup_ui()

func _setup_ui():
	creature_list = get_node_or_null("CreatureList")
	item_list = get_node_or_null("ItemList")
	achievement_list = get_node_or_null("AchievementList")
	
	# Connect InventoryManager signals
	InventoryManager.inventory_updated.connect(_on_inventory_updated)

func _on_inventory_updated():
	print("Inventory updated in UI")
	_update_creature_list()
	_update_item_list()
	_update_achievement_list()

func _update_creature_list():
	if not creature_list:
		return
	
	creature_list.clear()
	
	var active_squad = InventoryManager.get_active_squad()
	var storage = InventoryManager.get_creature_storage()
	
	creature_list.add_item("Active Squad (" + str(active_squad.size()) + "/6)")
	for creature_id in active_squad:
		creature_list.add_item("  " + creature_id)
	
	creature_list.add_item("Storage (" + str(storage.size()) + ")")
	for creature_id in storage:
		creature_list.add_item("  " + creature_id)

func _update_item_list():
	if not item_list:
		return
	
	item_list.clear()
	
	var items = InventoryManager.get_items()
	for item_id in items:
		var quantity = items[item_id]
		item_list.add_item(item_id + " x" + str(quantity))

func _update_achievement_list():
	if not achievement_list:
		return
	
	achievement_list.clear()
	
	var achievements = InventoryManager.get_achievements()
	for achievement_id in achievements:
		achievement_list.add_item(achievement_id)

func filter_by_type(filter_type: String):
	print("Filtering by: ", filter_type)
	# Placeholder per filtri

func sort_inventory(sort_type: String):
	print("Sorting by: ", sort_type)
	# Placeholder per ordinamento
