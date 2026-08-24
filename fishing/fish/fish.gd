class_name Fish extends CharacterBody2D

@export var speed: float = 150.0

@onready var movement_update_timer: Timer = $MovementUpdateTimer
var should_update_movement: bool = true

@onready var edge_vision: RayCast2D = $EdgeVision
@export var pond_center: Marker2D

@onready var scare_timer = $ScareTimer
var scared: bool = false
var scared_position: Vector2

@onready var detection_area = $DetectionArea
var chasing: bool = false
var chase_target: Vector2
var can_be_reeled_in: bool = false

func _physics_process(delta: float) -> void:
	if not scared:
		check_bobber()
		check_reel_in_distance()
	
	if should_update_movement:
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
	
	if scared:
		var direction_from_scare = global_position.direction_to(scared_position)
		new_x = -direction_from_scare.x
		new_y = -direction_from_scare.y
	elif chasing:
		var direction_to_target = global_position.direction_to(chase_target)
		new_x = direction_to_target.x
		new_y = direction_to_target.y
	elif edge_vision.is_colliding():
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

func tween_rotation(target_angle: float) -> void:
	var tween = create_tween()
	var current_angle = rotation
	var diff = wrapf(target_angle - current_angle, -PI, PI)
	var final_target = current_angle + diff
	tween.tween_property(self, "rotation", final_target, 0.2)

func get_scared(scare_position: Vector2) -> void:
	print("scared")
	if scared:
		return
		
	scared = true
	should_update_movement = true
	speed *= 2
	scared_position = scare_position
	scare_timer.start()

func _on_movement_update_timer_timeout() -> void:
	should_update_movement = true

func _on_scare_timer_timeout() -> void:
	speed /= 2
	scared = false

func check_bobber() -> void:
	var potential_bobbers = detection_area.get_overlapping_areas()
	if potential_bobbers.is_empty():
		return
		
	var bobber: Bobber
	for area in potential_bobbers:
		if area.is_in_group("bobber"):
			bobber = area
			
	var can_chase = bobber.set_chasing_fish(self)
	
	if can_chase:
		chasing = true
		chase_target = bobber.global_position

func check_reel_in_distance() -> void:
	if global_position.distance_to(chase_target) < 30:
		can_be_reeled_in = true
	else:
		can_be_reeled_in = false

func reel_in() -> void:
	if can_be_reeled_in:
		print("Caught a fish!")
		queue_free()
	else:
		chasing = false
