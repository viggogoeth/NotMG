extends Node


var zoom_level: float = 1.0


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
