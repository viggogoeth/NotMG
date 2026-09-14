extends Node

@export var dash_cooldown: float = 5
@export var dash_duration: float = 0.45
@export var dash_speed_factor: float = 6.5
@export var enemy: CharacterBody2D

@onready var dash_cooldown_timer = $DashCooldown
@onready var dash_duration_timer = $DashDuration
@onready var windup_duration_timer = $WindupDuration
@onready var post_attack_cooldown = $PostAttackCooldown

var can_dash: bool = false
var dashing: bool = false

var dash_target: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_duration_timer.wait_time = dash_duration

func try_attack(target: CharacterBody2D) -> bool:
	if can_dash and not dashing:
		if target:
			windup_duration_timer.start()
			# TODO: start the windup animation
			dashing = true
			dash_target = target

	return dashing

func _dash_attack() -> void:
	# TODO: start the dash attack animation
	var direction = enemy.global_position.direction_to(dash_target.global_position)
	enemy.velocity = direction * enemy.speed * dash_speed_factor
	var velocity_tween = create_tween()
	velocity_tween.set_ease(velocity_tween.EASE_OUT)
	velocity_tween.tween_property(enemy, "velocity", enemy.velocity / 3, dash_duration - 0.1)
	can_dash = false
	dash_duration_timer.start()


func _on_windup_duration_timeout() -> void:
	_dash_attack()	

func _on_dash_duration_timeout() -> void:
	enemy.velocity = Vector2(0,0)
	post_attack_cooldown.start()
	
func _on_dash_cooldown_timeout() -> void:
	can_dash = true


func _on_post_attack_cooldown_timeout() -> void:
	dashing = false
	dash_cooldown_timer.start()
