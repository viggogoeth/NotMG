extends CharacterBody2D

@export var projectile_scene : PackedScene = preload("res://entities/projectile.tscn")
@onready var projectile_spawn : Marker2D = $ProjectileSpawn

const SPEED: float = 400.0
const I_FRAMES: float = 0.4
var can_take_damage: bool = true
var attack_cooldown : float = 0.1
var can_attack : bool = true

# For animation
enum Direction {LEFT, RIGHT, UP, DOWN}
var last_direction = Direction.DOWN

func _ready() -> void:
	add_to_group("persistent")
	$AnimatedSprite2D.play()
	$AttackTimer.wait_time = attack_cooldown
	$IFrameTimer.wait_time = I_FRAMES
	$HealthComponent.max_health = 100.0
	$HealthComponent.current_health = 100.0

func _physics_process(delta: float) -> void:
	#print($HealthComponent.current_health)
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED

	_handle_animation_direction(velocity)

	move_and_slide()
	
	if Input.is_action_pressed("main_attack") and can_attack:
		can_attack = false
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
	can_attack = true

func take_damage(amount: float) -> void:
	if can_take_damage:
		$HealthComponent.take_damage(amount)
		can_take_damage = false
		$IFrameTimer.start()

func die() -> void:
	print("THE PLAYER IS DEAD")


func _on_i_frame_timer_timeout() -> void:
	can_take_damage = true
	
	var bodies = $HitBox.get_overlapping_bodies()
	if not bodies.is_empty():
		var body = bodies[0]
		take_damage(body.CONTACT_DAMAGE)
		

func save_data() -> Dictionary:
	print("Saving current health %f" % $HealthComponent.current_health)
	return {"current_health": $HealthComponent.current_health}
	
func load_data(save_data: Dictionary) -> void:
	print("Loading current health %f" % save_data["current_health"])
	$HealthComponent.current_health = save_data["current_health"]
