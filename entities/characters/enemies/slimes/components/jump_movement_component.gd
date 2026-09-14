extends Node

@export var movement_cooldown: float = 0.65
@export var movement_duration: float = 0.5
@export var enemy: CharacterBody2D

var should_update_movement: bool = false
var moving: bool = false

var RNG = RandomNumberGenerator.new()

func _ready() -> void:
	$MoveCooldown.wait_time = movement_cooldown
	$MoveDuration.wait_time = movement_duration
	$MoveCooldown.start()


func move(target: CharacterBody2D) -> void:
	if should_update_movement and not moving:
		should_update_movement = false
		moving = true
		enemy.set_moving()
		
		# if multiple enemies moving, dont want to clump up
		var random_move_delay_offset = RNG.randf_range(-0.1, 0.1)
		$MoveCooldown.wait_time = movement_cooldown + random_move_delay_offset
		$MoveDuration.start()
		
		if target:
			var direction = enemy.global_position.direction_to(target.global_position)
			enemy.velocity = direction * enemy.speed
		else: # idle movement
			var dir_x = RNG.randf_range(-0.5, 0.5)
			var dir_y = RNG.randf_range(-0.5, 0.5)
			var direction = Vector2(dir_x, dir_y)
			enemy.velocity = direction * enemy.speed
		
	
	

func _on_move_cooldown_timeout() -> void:
	should_update_movement = true

func _on_move_duration_timeout() -> void:
	moving = false
	enemy.velocity = Vector2(0,0)
	enemy.set_idle()
	$MoveCooldown.start()
