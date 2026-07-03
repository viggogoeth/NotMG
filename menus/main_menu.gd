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
	var load_data = WorldManager.get_load_data()
	_start_game(load_data["current_map"])


func _on_new_game_button_pressed() -> void:
	PlayerVariables.reset_player_variables()
	_start_game(MAIN_LEVEL)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
