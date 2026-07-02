extends ColorRect

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func random_green():
	var red = rng.randf_range(0.0, 0.3)
	var green = rng.randf_range(0.6, 1.0)
	var blue = rng.randf_range(0.0, 0.3)
	return Color(red, green, blue, 1)
