extends Node2D

signal change_state(state: SlimeBoss.State)

@export var movement_speed: float = 400

@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_duration: Timer = $AttackDuration
@onready var movement_cooldown: Timer = $MovementCooldown
@onready var movement_duration: Timer = $MovementDuration

@export var boss: SlimeBoss
var player: Player

func _ready() -> void:
	player = boss.player

var can_attack: bool = false
var should_update_movement: bool = false

func update_movement() -> void:
	var direction = boss.global_position.direction_to(player.global_position)
	boss.velocity = direction * movement_speed
	movement_duration.start()
	change_state.emit(SlimeBoss.State.moving)

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_movement_cooldown_timeout() -> void:
	update_movement()

func _on_movement_duration_timeout() -> void:
	boss.velocity = Vector2.ZERO
	movement_cooldown.start()
	WorldManager.camera.add_shake_trauma(0.25)
	change_state.emit(SlimeBoss.State.idle)
