class_name Bam extends Sprite2D

@onready var lifetime: Timer = $Lifetime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = load("res://sprites/bams/bam_1.png") # TODO: make random
	
	global_position.x += randf_range(-16,16)
	global_position.y += randf_range(-16,16)
	
	create_tween().tween_property(self, "scale", scale*1.3, 0.2)
	lifetime.start()

func _on_lifetime_timeout() -> void:
	queue_free()
