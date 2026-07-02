extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_data() -> Dictionary:
	var current_scene = get_tree().get_current_scene().scene_file_path
	return {"current_map": current_scene}
