extends Node

var movement_cooldown: float = 0.65
var movement_duration: float = 0.5
var should_update_movement: bool = false
var moving: bool = false

var RNG = RandomNumberGenerator.new()

var host_enemy: CharacterBody2D

func _ready() -> void:
	$MoveCooldown.wait_time = movement_cooldown
	$MoveDuration.wait_time = movement_duration
	$MoveCooldown.start()

func set_host(host: CharacterBody2D) -> void:
	host_enemy = host

func move() -> void:
	if should_update_movement and not moving:
		should_update_movement = false
		moving = true
		
		var random_move_delay_offset = RNG.randf_range(-0.1, 0.1)
		$MoveCooldown.wait_time = movement_cooldown + random_move_delay_offset
		
		if host_enemy.target_player != null:
			var direction = host_enemy.global_position.direction_to(host_enemy.target_player.global_position)
			host_enemy.velocity = direction * host_enemy.speed
		else: # idle movement
			var dir_x = RNG.randf_range(-0.5, 0.5)
			var dir_y = RNG.randf_range(-0.5, 0.5)
			var direction = Vector2(dir_x, dir_y)
			host_enemy.velocity = direction * host_enemy.speed
		
	if moving:
		host_enemy.move_and_slide()
	

func _on_move_cooldown_timeout() -> void:
	should_update_movement = true
	host_enemy.move_start()
	$MoveDuration.start()

func _on_move_duration_timeout() -> void:
	moving = false
	host_enemy.move_stop()
	$MoveCooldown.start()
