class_name Map extends Node

@export var player: Player

@export var map_cleared: bool = false

const PAUSE_MENU_SCENE = preload("res://menus/pause_menu.tscn")
const INVENTORY_MENU_SCENE = preload("res://menus/inventory_menu.tscn")
const GAME_OVER_MENU_SCENE = preload("res://menus/game_over_menu.tscn")
const LOOT_BAG_MENU_SCENE = preload("res://menus/loot_bag_menu.tscn")

var inventory_node: InventoryMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(PAUSE_MENU_SCENE.instantiate())
	inventory_node = INVENTORY_MENU_SCENE.instantiate()
	add_child(inventory_node)
	add_child(GAME_OVER_MENU_SCENE.instantiate())
	add_child(LOOT_BAG_MENU_SCENE.instantiate())
	player = get_tree().get_first_node_in_group("player")
	await get_tree().process_frame
	_load_data()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _load_data() -> void:
	var data = ResourceLoader.load("user://save_data.tres") as SaveData
	
	if data:
		player.set_health(data.max_health, data.current_health)
		player.current_level = data.current_level
		player.current_exp = data.current_exp
		player.stats = data.stats as PlayerStats
		player.equipped_weapon = data.equipped_weapon as SlotData
		player.inventory = data.inventory as InventoryData
		
		inventory_node.update_item_slots()
		
		if data.map_cleared:
			var enemies_in_scene = get_tree().get_nodes_in_group("enemy")
			for enemy in enemies_in_scene:
				enemy.queue_free()

func _on_enemy_tree_exited() -> void:
	map_cleared = true
	print("Map Cleared!")
