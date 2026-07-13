class_name Map extends Node

@export var player: Player

@export var map_cleared: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	await get_tree().process_frame
	_load_data()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _load_data() -> void:
	var data = ResourceLoader.load("user://save_data.tres") as SaveData
	
	if data:
		player.current_health = data.current_health
		player.current_level = data.current_level
		player.current_exp = data.current_exp
		player.stats = data.stats as PlayerStats
		player.equipped_weapon = data.equipped_weapon as WeaponData
		print("loaded player with vigor = ", player.stats.vigor)
		
		if data.map_cleared:
			var enemies_in_scene = get_tree().get_nodes_in_group("enemy")
			for enemy in enemies_in_scene:
				enemy.queue_free()

func _on_enemy_tree_exited() -> void:
	map_cleared = true
	print("Map Cleared!")
