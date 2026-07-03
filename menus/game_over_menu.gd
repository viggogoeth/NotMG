extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PlayerVariables.is_dead:
		get_tree().paused = true
		show()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file(WorldManager.MAIN_MENU)


func _on_load_button_pressed() -> void:
	var load_data = WorldManager.get_load_data()
	var loaded_scene = load_data["current_map"]
	get_tree().paused = false
	get_tree().change_scene_to_file(loaded_scene)
