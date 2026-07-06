extends CanvasLayer

const MAIN_MENU: String = "res://menus/main_menu.tscn"

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
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

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file(WorldManager.MAIN_MENU)


func _on_quick_save_button_pressed() -> void:
	_save_data()

func _on_save_quit_button_pressed() -> void:
	_save_data()
	get_tree().change_scene_to_file(WorldManager.MAIN_MENU)

func _save_data() -> void:
	var data = SaveData.new()
	data.current_health = player.current_health
	data.current_level = player.current_level
	data.current_exp = player.current_exp
	
	data.current_scene = get_tree().current_scene.scene_file_path
	# TODO: add the rest of the stuff

	ResourceSaver.save(data, "user://save_data.tres")
	print("Saving data.")
