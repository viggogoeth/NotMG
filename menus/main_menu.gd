extends Control

const MAIN_LEVEL: String = "res://maps/dojo_map.tscn"

var current_scene: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/HBoxContainer/HBoxContainer/AnimatedSprite2D.play()
	if Config.player_color:
		$ColorPickerButton.color = Config.player_color
		$MarginContainer/HBoxContainer/HBoxContainer/AnimatedSprite2D.modulate = Config.player_color
	else:
		$ColorPickerButton.color = Color("red")
		$MarginContainer/HBoxContainer/HBoxContainer/AnimatedSprite2D.modulate = Color("red")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _start_game(scene: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(scene)

func _on_continue_button_pressed() -> void:
	_load_data()
	if current_scene != "":
		_start_game(current_scene)
	else:
		_start_game("res://maps/dojo_map.tscn")


func _on_new_game_button_pressed() -> void:
	var path = "user://save_data.tres"
	var backup_path = "user://save_data_backup.tres"
	DirAccess.rename_absolute(path, backup_path)

	_start_game(MAIN_LEVEL)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _load_data() -> void:
	var data = ResourceLoader.load("user://save_data.tres") as SaveData
	if data:
		current_scene = data.current_scene
	
func _on_color_picker_color_changed(color: Color) -> void:
	$MarginContainer/HBoxContainer/HBoxContainer/AnimatedSprite2D.modulate = color
	Config.player_color = color
