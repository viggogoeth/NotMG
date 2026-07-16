extends Node

# UI globals
var zoom_level: float = 1.0

# const values
const MAIN_MENU: String = "res://menus/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func switch_world(target_scene_path: String) -> void:
	call_deferred("_deferred_switch", target_scene_path)

func _deferred_switch(path: String) -> void:
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		print("Error loading scene: %s" % path)

func save_data(player: Player, map_scene: String, map_cleared: bool) -> void:
	var data = SaveData.new()
	data.current_health = player.current_health
	data.max_health = player.max_health
	data.current_level = player.current_level
	data.current_exp = player.current_exp
	data.stats = player.stats
	data.equipped_weapon = player.equipped_weapon
	data.inventory = player.inventory
	
	data.map_cleared = map_cleared
	data.current_scene = map_scene

	ResourceSaver.save(data, "user://save_data.tres")
	print("Saving data.")
