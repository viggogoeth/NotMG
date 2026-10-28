class_name Bam extends Sprite2D

@onready var lifetime: Timer = $Lifetime
@onready var sound_effect_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var min_pitch: float = 0.8
var max_pitch: float = 1.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = load("res://sprites/bams/bam_1.png") # TODO: make random
	
	global_position.x += randf_range(-16,16)
	global_position.y += randf_range(-16,16)
	
	create_tween().tween_property(self, "scale", scale*1.3, 0.2)
	lifetime.start()
	
	sound_effect_player.pitch_scale = randf_range(min_pitch, max_pitch)
	sound_effect_player.play()

func _on_lifetime_timeout() -> void:
	queue_free()
