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

func get_load_data() -> Dictionary:
	var file = "res://save_data.json"
	var save_data_text = FileAccess.get_file_as_string(file)
	var save_data_json = JSON.parse_string(save_data_text)

	#var persistent_nodes = get_tree().get_nodes_in_group("persistent")
	#for node in persistent_nodes:
	#	if node.has_method("load_data"):
	#		node.load_data(save_data_json)
	
	#TODO: make this change explicitly stated in function name (new function)
	PlayerVariables.set_player_variables_from_save_data(save_data_json)
	
	return save_data_json
