extends CanvasLayer

const MAIN_MENU: String = "res://menus/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state



func _on_resume_button_pressed() -> void:
	toggle_pause()

func save_data() -> void:
	var filepath = "res://save_data.json"
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	
	var persistent_nodes = get_tree().get_nodes_in_group("persistent")
	var save_dict = {}
	for node in persistent_nodes:
		var node_data = node.save_data()
		for key in node_data:
			save_dict[key] = node_data[key]
		
	var data_json = JSON.stringify(save_dict)
	file.store_line(data_json)

func _on_quit_button_pressed() -> void:
	save_data()
	
	get_tree().change_scene_to_file(MAIN_MENU)
