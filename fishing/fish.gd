extends CharacterBody2D


const SPEED = 150.0

@onready var movement_update_timer = $MovementUpdateTimer
var should_update_movement: bool = true

@onready var edge_vision = $EdgeVision

var rod_charge: float = 0

func _physics_process(delta: float) -> void:
	var rand = RandomNumberGenerator.new()
	
	if should_update_movement:
		var tween = create_tween()
		update_movement()
		should_update_movement = false
		movement_update_timer.start()
		
	move_and_slide()
	
	if Input.is_action_pressed("main_attack"):
		charge_rod(delta)
	
	if Input.is_action_just_released("main_attack"):
		release_rod()

func update_movement() -> void:
	var rand = RandomNumberGenerator.new()
	var tween = create_tween()
	
	var old_direction = velocity.normalized()
	var new_x: float
	var new_y: float
	if edge_vision.is_colliding():
		new_x = -old_direction.x
		new_y = -old_direction.y
	else:
		new_x = old_direction.x + rand.randf_range(-0.2, 0.2)
		new_y = old_direction.y + rand.randf_range(-0.2, 0.2)
	var new_direction = Vector2(new_x, new_y)
	
	print(new_direction)
	
	#tween.tween_property(self, "velocity", Vector2(0,0), 0.2)
	var new_velocity = new_direction * SPEED
	#velocity = new_velocity
	tween.tween_property(self, "velocity", new_velocity, 0.2)
	
	var new_rotation = new_direction.angle() + PI / 2
	#tween.tween_property(self, "rotation", new_rotation, 0.2)
	rotation = new_rotation

func charge_rod(delta: float) -> void:
	if rod_charge < 100:
		rod_charge += 1 * delta
	else:
		rod_charge = 100
		
func release_rod() -> void:
	print("Released rod at %.2f charge" % rod_charge)

func _on_movement_update_timer_timeout() -> void:
	should_update_movement = true
