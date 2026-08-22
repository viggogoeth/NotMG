extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var movement_update_timer = $MovementUpdateTimer
var should_update_movement: bool = true

func _physics_process(delta: float) -> void:
	var rand = RandomNumberGenerator.new()
	
	if should_update_movement:
		var tween = create_tween()
		var direction = Vector2(rand.randf_range(-1, 1), rand.randf_range(-1,1))
		
		tween.tween_property(self, "velocity", direction * SPEED, 0.1)
		should_update_movement = false
		movement_update_timer.start()
		
		#var old_rotation = rotation
		var new_rotation = direction.normalized().angle() + PI / 2
		tween.tween_property(self, "rotation", new_rotation, 0.2)
		
	
	move_and_slide()


func _on_movement_update_timer_timeout() -> void:
	should_update_movement = true
