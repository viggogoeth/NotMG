extends Node

var movement_cooldown: float = 0.65
var movement_duration: float = 0.5
var should_update_movement: bool = false
var moving: bool = false

var RNG = RandomNumberGenerator.new()

func _ready() -> void:
	$MoveCooldown.wait_time = movement_cooldown
	$MoveDuration.wait_time = movement_duration
	$MoveCooldown.start()


func move(enemy: CharacterBody2D) -> void:
	if should_update_movement and not moving:
		should_update_movement = false
		moving = true
		
		var random_move_delay_offset = RNG.randf_range(-0.1, 0.1)
		$MoveCooldown.wait_time = movement_cooldown + random_move_delay_offset
		
		if enemy.target_player != null:
			var direction = enemy.global_position.direction_to(enemy.target_player.global_position)
			enemy.velocity = direction * enemy.speed
		else: # idle movement
			var dir_x = RNG.randf_range(-0.5, 0.5)
			var dir_y = RNG.randf_range(-0.5, 0.5)
			var direction = Vector2(dir_x, dir_y)
			enemy.velocity = direction * enemy.speed
		
	if moving:
		enemy.move_and_slide()
	

func _on_move_cooldown_timeout() -> void:
	should_update_movement = true
	$MoveDuration.start()

func _on_move_duration_timeout() -> void:
	moving = false
	$MoveCooldown.start()
