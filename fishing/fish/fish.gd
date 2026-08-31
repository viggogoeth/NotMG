class_name Fish extends CharacterBody2D

@export var base_speed: float = 100.0
var speed: float = base_speed

@onready var movement_update_timer: Timer = $MovementUpdateTimer
var should_update_direction: bool = true

@onready var edge_vision = $EdgeVision
@export var pond_center: Marker2D

@onready var scare_timer = $ScareTimer
var scared: bool = false
var scared_position: Vector2

@onready var detection_area = $DetectionArea
var chasing: bool = false
var speedy_chasing: bool = false

@export var reel_in_time: float = 0.2

@onready var reel_in_timer = $ReelInTimer
@onready var reel_in_indicator = $ReelInIndicator
@onready var interest_timer = $InterestTimer
@onready var interest_indicator = $InterestIndicator
var bobber: Bobber
var can_be_reeled_in: bool = false

@onready var animation = $AnimationPlayer
@onready var sprite_side = $Sprite2D
@onready var sprite_top = $Sprite2D2

@export var texture: Texture2D

var rand = RandomNumberGenerator.new()

var fish_spawner: FishSpawner = null

var paused: bool = false

func _ready() -> void:
	texture = sprite_side.texture
	reel_in_indicator.hide()
	reel_in_timer.wait_time = reel_in_time
	interest_indicator.hide()
	animation.play("move_side")

func _physics_process(delta: float) -> void:
	if paused:
		return
		
	if not scared and not can_be_reeled_in:
		check_bobber()
		
	if chasing:	
		reel_in_indicator.rotation = -rotation
		interest_indicator.rotation = -rotation
		check_reel_in_distance()
	
	if should_update_direction and not can_be_reeled_in:
		update_movement()
		should_update_direction = false
		movement_update_timer.start()
	
	if chasing and not can_be_reeled_in:
		if not speedy_chasing:
			speed = 10
			if rand.randi_range(0,100) == 10:
				speed = base_speed * 3
				speedy_chasing = true
	
	if can_be_reeled_in:
		velocity = Vector2(0,0)
	
	move_and_slide()
	update_animation()

func update_animation() -> void:
	var speed_ratio = speed / base_speed
	animation.speed_scale = speed_ratio
	
	var direction = velocity.normalized()
	if abs(direction.y) > 3 * abs(direction.x):
		animation.play("move_top")
		sprite_side.hide()
		sprite_top.show()
	else:
		animation.play("move_side")
		sprite_side.show()
		sprite_top.hide()
		if direction.x < 0:
			sprite_side.flip_v = true
		else:
			sprite_side.flip_v = false
	
func update_movement() -> void:
	var new_direction: Vector2
	if scared:
		new_direction = _move_scared()
	elif chasing:
		new_direction = _move_chasing()
	elif edge_vision.is_colliding():
		new_direction = _move_from_edge()
	else:
		var old_direction = velocity.normalized()
		new_direction = _move_random(old_direction)
	
	_update_rotation(new_direction)

func _update_rotation(new_direction: Vector2) -> void:
	var new_rotation = new_direction.angle() + PI / 2
	
	var current_angle = rotation
	var diff = wrapf(new_rotation - current_angle, -PI, PI)
	var final_target = current_angle + diff

	create_tween().tween_property(self, "rotation", final_target, 0.2)
	reel_in_indicator.rotation = -rotation

func get_scared(scare_position: Vector2) -> void:
	print("scared")
	if scared:
		return
	
	#modulate = Color("blue", 0.2)	
	create_tween().tween_property(self, "modulate", Color("blue", 0.2), 0.2)
	
	scared = true
	should_update_direction = true
	speed = base_speed * 2
	scared_position = scare_position
	scare_timer.start()

func _on_movement_update_timer_timeout() -> void:
	should_update_direction = true

func _on_scare_timer_timeout() -> void:
	#modulate = Color("white")
	create_tween().tween_property(self, "modulate", Color("white"), 0.2)
	speed = base_speed
	scared = false
	
	# TODO: is this cool? 
	if rand.randf() < 0.50:
		_remove_fish()

func _remove_fish() -> void:
	if fish_spawner:
		fish_spawner.fish_killed()
	queue_free()

func check_bobber() -> void:
	var potential_bobbers = detection_area.get_overlapping_areas()
	if potential_bobbers.is_empty():
		return
		
	var potential_bobber: Bobber
	for area in potential_bobbers:
		if area.is_in_group("bobber"):
			potential_bobber = area
			
	var can_chase = potential_bobber.set_chasing_fish(self)
	
	if can_chase:
		chasing = true
		bobber = potential_bobber
		#should_update_direction = true # TODO: is this better or worse?
		interest_indicator.show()
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(interest_indicator, "scale", Vector2(2,2), 0.2)
		#tween.set_ease(Tween.EASE_IN)
		tween.tween_property(interest_indicator, "scale", Vector2(1,1), 0.1)
		interest_timer.start()
		

func check_reel_in_distance() -> void:
	if can_be_reeled_in:
		return
		
	if global_position.distance_to(bobber.global_position) < 30:
		can_be_reeled_in = true
		reel_in_timer.start()
		reel_in_indicator.show()
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(reel_in_indicator, "scale", Vector2(3,3), reel_in_time)
		tween.tween_property(reel_in_indicator, "scale", Vector2(1,1), 0.1)
	else:
		can_be_reeled_in = false

func reel_in(bobber_position: Vector2) -> bool:
	if can_be_reeled_in:
		print("Caught a fish!")
		_remove_fish()
		return true
	else:
		chasing = false
		speedy_chasing = false
		get_scared(bobber_position)
		bobber = null
		return false

func _update_velocity(new_direction: Vector2) -> void:
	var tween = create_tween()
	var new_velocity = new_direction * speed
	tween.tween_property(self, "velocity", new_velocity, 0.2)

func _move_scared() -> Vector2:
	var direction_from_scare = global_position.direction_to(scared_position)
	var new_x = -direction_from_scare.x
	var new_y = -direction_from_scare.y
	var new_direction = Vector2(new_x, new_y)
	_update_velocity(new_direction)
	return new_direction
	
func _move_chasing() -> Vector2:
	var direction_to_target = global_position.direction_to(bobber.global_position)
	var new_x = direction_to_target.x
	var new_y = direction_to_target.y
	var new_direction = Vector2(new_x, new_y)
	_update_velocity(new_direction)
	return new_direction
	
func _move_random(old_direction: Vector2) -> Vector2:
	var new_x = old_direction.x + rand.randf_range(-0.2, 0.2)
	var new_y = old_direction.y + rand.randf_range(-0.2, 0.2)
	var new_direction = Vector2(new_x, new_y)
	_update_velocity(new_direction)
	return new_direction
	
func _move_from_edge() -> Vector2:
	var old_direction = velocity.normalized()
	var total_rotation = 0.0
	var old_rotation = rotation
	var facing_wall = true
	
	var rotate_right = rand.randf() < 0.15
	
	while facing_wall:
		if rotate_right:
			total_rotation += 0.05
			rotate(0.05)
		else:
			total_rotation -= 0.05
			rotate(-0.05)
		# check if still facing wall	
		edge_vision.force_raycast_update()
		print(total_rotation)
		if not edge_vision.is_colliding():
			facing_wall = false
	
	rotation = old_rotation		
	
	var new_direction = old_direction.rotated(total_rotation)
	_update_velocity(new_direction)
	return new_direction

func _on_reel_in_timer_timeout() -> void:
	can_be_reeled_in = false
	reel_in_indicator.hide()
	reel_in_indicator.scale = Vector2(1,1)
	get_scared(bobber.global_position)
	bobber.return_bobber()

func set_center(center: Marker2D) -> void:
	pond_center = center

func set_spawner(spawner: FishSpawner) -> void:
	fish_spawner = spawner

func _on_interest_timer_timeout() -> void:
	interest_indicator.hide()
	interest_indicator.scale = Vector2(1,1)

func toggle_physics() -> void:
	paused = not paused
	if paused:
		animation.pause()
	else:
		animation.play()
