extends Control

const MAIN_LEVEL: String = "res://maps/dojo_map.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/HBoxContainer/HBoxContainer/AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _start_game(scene: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(scene)

func _on_continue_button_pressed() -> void:
	var file = "res://save_data.json"
	var save_data_text = FileAccess.get_file_as_string(file)
	var save_data_json = JSON.parse_string(save_data_text)

	var persistent_nodes = get_tree().get_nodes_in_group("persistent")
	for node in persistent_nodes:
		if node.has_method("load_data"):
			node.load_data(save_data_json)

	_start_game(save_data_json["current_map"])


func _on_new_game_button_pressed() -> void:
	_start_game(MAIN_LEVEL)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
