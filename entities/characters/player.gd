extends CharacterBody2D

@export var projectile_scene : PackedScene = preload("res://entities/projectile.tscn")
@onready var projectile_spawn : Marker2D = $ProjectileSpawn



# For animation
enum Direction {LEFT, RIGHT, UP, DOWN}
var last_direction = Direction.DOWN

func _ready() -> void:
	$AnimatedSprite2D.play()
	$AttackTimer.wait_time = PlayerVariables.attack_cooldown
	$IFrameTimer.wait_time = PlayerVariables.I_FRAMES
	$HealthComponent.set_health(PlayerVariables.max_health, PlayerVariables.current_health)
	PlayerVariables.can_attack = true
	PlayerVariables.can_take_damage = true
	
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * PlayerVariables.movement_speed

	_handle_animation_direction(velocity)

	move_and_slide()
	
	if Input.is_action_pressed("main_attack") and PlayerVariables.can_attack:
		PlayerVariables.can_attack = false
		$AttackTimer.start()
		_attack()
		
func _attack():
	var projectile1 = projectile_scene.instantiate()
	var projectile2 = projectile_scene.instantiate()
	
	var attack_direction = (get_global_mouse_position() - projectile_spawn.global_position).normalized()
	
	projectile1.global_position = projectile_spawn.global_position
	projectile2.global_position = projectile_spawn.global_position
	projectile1.direction = attack_direction
	projectile2.direction = attack_direction
	
	projectile2.inversed = true
	
	
	get_owner().add_child(projectile1)
	get_owner().add_child(projectile2)

func _handle_animation_direction(velocity: Vector2) -> void:
	if velocity.length() == 0:
		match last_direction:
			Direction.RIGHT:
				$AnimatedSprite2D.animation = "idle_side"
				$AnimatedSprite2D.flip_h = false
			Direction.LEFT:
				$AnimatedSprite2D.animation = "idle_side"
				$AnimatedSprite2D.flip_h = true
			Direction.UP:
				$AnimatedSprite2D.animation = "idle_back"
			Direction.DOWN:
				$AnimatedSprite2D.animation = "idle_front"
			_:
				push_error("Unsupported Direction for 'handle_animation_direction': %s" % last_direction)
	else:
		if velocity.y > 0 and velocity.x == 0:
			$AnimatedSprite2D.animation = "walk_front"
			last_direction = Direction.DOWN
		elif velocity.y < 0 and velocity.x == 0:
			$AnimatedSprite2D.animation = "walk_back"
			last_direction = Direction.UP
		
		if velocity.x > 0:
			$AnimatedSprite2D.animation = "walk_side"
			$AnimatedSprite2D.flip_h = false
			last_direction = Direction.RIGHT
		elif velocity.x < 0:
			$AnimatedSprite2D.animation = "walk_side"
			$AnimatedSprite2D.flip_h = true
			last_direction = Direction.LEFT


func _on_attack_timer_timeout() -> void:
	PlayerVariables.can_attack = true

func take_damage(amount: float) -> void:
	if PlayerVariables.can_take_damage:
		$HealthComponent.take_damage(amount)
		PlayerVariables.can_take_damage = false
		PlayerVariables.current_health = $HealthComponent.current_health
		$IFrameTimer.start()
		
		var tween = create_tween()
		tween.tween_property($AnimatedSprite2D, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property($AnimatedSprite2D, "scale", Vector2(1, 1), 0.05)

func die() -> void:
	PlayerVariables.is_dead = true
	print("THE PLAYER IS DEAD")


func _on_i_frame_timer_timeout() -> void:
	PlayerVariables.can_take_damage = true
	
	var bodies = $HitBox.get_overlapping_bodies()
	if not bodies.is_empty():
		var body = bodies[0]
		take_damage(body.contact_damage)
		

func save_data() -> Dictionary:
	return {"current_health": PlayerVariables.current_health, 
			"current_level": PlayerVariables.current_level,
			"current_exp": PlayerVariables.current_exp}
	
func load_data(save_data: Dictionary) -> void:
	pass


func _on_regen_timer_timeout() -> void:
	$HealthComponent.heal(PlayerVariables.regen_rate)
	PlayerVariables.current_health = $HealthComponent.current_health
