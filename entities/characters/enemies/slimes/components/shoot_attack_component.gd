extends Node2D

@export var shoot_cooldown: float = 5
@export var shoot_pause: float = 0.35

@onready var shoot_cooldown_timer: Timer = $ShootCooldown
@onready var shoot_pause_timer: Timer = $ShootPause
@onready var windup_duration_timer: Timer = $WindupDuration
@onready var post_attack_cooldown_timer: Timer = $PostAttackCooldown

var shoot_target: CharacterBody2D
@export var enemy: CharacterBody2D

@export var total_shots: int = 5
var remaining_shots: int = 0
var shooting: bool = false

@export var projectile_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shoot_cooldown_timer.wait_time = shoot_cooldown
	shoot_pause_timer.wait_time = shoot_pause
	enemy.first_target_seen.connect(shoot_cooldown_timer.start)

func try_attack(target: CharacterBody2D) -> bool:
	if remaining_shots > 0 and not shooting:
		if target:
			shoot_pause_timer.start()
			shooting = true
			shoot_target = target
			enemy.winding.emit()
			enemy.base_velocity = Vector2.ZERO

	return shooting

func _shoot_attack() -> void:
	var direction = enemy.global_position.direction_to(shoot_target.global_position)
	enemy.shooting.emit(direction)
	remaining_shots -= 1
	
	# do the shot
	var projectile = projectile_scene.instantiate()
	projectile.set_collision_mask_by_shooter("enemy")
	projectile.set_pattern("straight_pattern")
	projectile.direction = direction
	projectile.max_range = 1000
	projectile.set_color(enemy.color)
	projectile.global_position = enemy.global_position
	get_tree().root.add_child(projectile)
	
	if remaining_shots == 0:
		post_attack_cooldown_timer.start()
		shooting = true
	else:
		shooting = false

func _on_shoot_cooldown_timeout() -> void:
	remaining_shots = total_shots

func _on_shoot_pause_timeout() -> void:
	_shoot_attack()

func _on_post_attack_cooldown_timeout() -> void:
	shoot_cooldown_timer.start()
	shooting = false
