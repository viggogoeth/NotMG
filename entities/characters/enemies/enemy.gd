extends CharacterBody2D

var target_player: CharacterBody2D
var exp_range_player: CharacterBody2D

@export var speed = 400.0
@export var health: float = 100.0

var movement_cooldown: float = 0.65
var movement_duration: float = 0.5
var should_update_movement: bool = false
var moving: bool = false
var dead: bool = false

var RNG = RandomNumberGenerator.new()

@export var resistance: float = 0.15
@export var contact_damage: float = 5.0

@export var exp_amount: float = 10.0

@export var color: Color = Color(1,1,1)

func _ready() -> void:
	$AnimatedSprite2D.play()
	$MoveCooldown.wait_time = movement_cooldown
	$MoveDuration.wait_time = movement_duration
	$MoveCooldown.start()
	$HealthComponent.set_health(health, health)
	$AnimatedSprite2D.self_modulate = color

func _physics_process(delta: float) -> void:
	if should_update_movement and not moving:
		should_update_movement = false
		moving = true
		
		var random_move_delay_offset = RNG.randf_range(-0.1, 0.1)
		$MoveCooldown.wait_time = movement_cooldown + random_move_delay_offset
		
		if target_player != null:
			var direction = global_position.direction_to(target_player.global_position)
			velocity = direction * speed
		else: # idle movement
			var dir_x = RNG.randf_range(-0.5, 0.5)
			var dir_y = RNG.randf_range(-0.5, 0.5)
			var direction = Vector2(dir_x, dir_y)
			velocity = direction * speed
		
	if moving:
		move_and_slide()
		
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

func take_damage(amount: float) -> void:
	var resist_adjusted_damage = amount * (1 - resistance)
	$HealthComponent.take_damage(resist_adjusted_damage)
	
func die() -> void:
	if dead:
		return
	dead = true
	exp_range_player.add_exp(exp_amount)
	queue_free()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)


func _on_move_cooldown_timeout() -> void:
	should_update_movement = true
	$AnimatedSprite2D.animation = "move"
	$MoveDuration.start()

func _on_move_duration_timeout() -> void:
	moving = false
	$AnimatedSprite2D.animation = "idle"
	$MoveCooldown.start()


func _on_vision_body_entered(body: Node2D) -> void:
	target_player = body
	exp_range_player = body # TODO: give this a different hitbox


func _on_vision_body_exited(body: Node2D) -> void:
	target_player = null
	exp_range_player = null
