class_name Fish extends CharacterBody2D

@export var speed: float = 150.0

@onready var movement_update_timer: Timer = $MovementUpdateTimer
var should_update_movement: bool = true

@onready var edge_vision: RayCast2D = $EdgeVision
@export var pond_center: Marker2D

func _physics_process(delta: float) -> void:
	var rand = RandomNumberGenerator.new()
	
	if should_update_movement:
		var tween = create_tween()
		update_movement()
		should_update_movement = false
		movement_update_timer.start()
		
	move_and_slide()
	
func update_movement() -> void:
	var rand = RandomNumberGenerator.new()
	var tween = create_tween()
	
	var old_direction = velocity.normalized()
	var new_x: float
	var new_y: float
	
	if edge_vision.is_colliding():
		var direction_to_center = global_position.direction_to(pond_center.global_position)
		new_x = direction_to_center.x
		new_y = direction_to_center.y
	else:
		new_x = old_direction.x + rand.randf_range(-0.2, 0.2)
		new_y = old_direction.y + rand.randf_range(-0.2, 0.2)
	
	
	var new_direction = Vector2(new_x, new_y)
	
	#tween.tween_property(self, "velocity", Vector2(0,0), 0.2)
	var new_velocity = new_direction * speed
	#velocity = new_velocity
	tween.tween_property(self, "velocity", new_velocity, 0.2)
	
	var new_rotation = new_direction.angle() + PI / 2
	tween_rotation(new_rotation)
	
func _dist_from_center() -> Vector2:
	var x_dist = abs(global_position.x - pond_center.x)
	var y_dist = abs(global_position.y - pond_center.y)
	return Vector2(x_dist, y_dist)

func tween_rotation(target_angle: float) -> void:
	var tween = create_tween()
	var current_angle = rotation
	var diff = wrapf(target_angle - current_angle, -PI, PI)
	var final_target = current_angle + diff
	tween.tween_property(self, "rotation", final_target, 0.2)



func _on_movement_update_timer_timeout() -> void:
	should_update_movement = true
