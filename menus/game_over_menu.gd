extends CanvasLayer

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.is_dead:
		get_tree().paused = true
		show()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file(WorldManager.MAIN_MENU)


func _on_load_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://maps/dojo_map.tscn")
