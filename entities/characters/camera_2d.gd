extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom.x = WorldManager.zoom_level
	zoom.y = WorldManager.zoom_level


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom_in"):
		if zoom.x < 5:
			zoom *= 1.2
	if Input.is_action_just_pressed("zoom_out"):
		if zoom.x > 0.2:
			zoom /= 1.2
	WorldManager.zoom_level = zoom.x
