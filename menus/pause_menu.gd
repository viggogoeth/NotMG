extends CanvasLayer

const MAIN_MENU: String = "res://menus/main_menu.tscn"

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	hide()
	print(visible)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event) -> void:
	if event.is_action_pressed("pause"):
		var menus = get_tree().get_nodes_in_group("menu")
		for menu in menus:
			if menu.visible == true and menu != self:
				return
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
	WorldManager.save_data(player, get_tree().current_scene.scene_file_path, get_tree().current_scene.map_cleared)
