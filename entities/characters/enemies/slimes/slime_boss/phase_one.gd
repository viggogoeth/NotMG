extends Node2D

signal change_state(state: SlimeBoss.State)

@export var movement_speed: float = 250

@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_duration: Timer = $AttackDuration
@onready var movement_cooldown: Timer = $MovementCooldown
@onready var movement_duration: Timer = $MovementDuration

@export var boss: SlimeBoss
var player: Player

var attacking: bool = false

func _ready() -> void:
	player = boss.player

func update_movement() -> void:
	var direction = boss.global_position.direction_to(player.global_position)
	boss.velocity = direction * movement_speed
	movement_duration.start()
	change_state.emit(SlimeBoss.State.moving)

func update_attack() -> void:
	boss.animated_sprite_2d.modulate = Color("darkgreen")
	print("attacking")
	change_state.emit(SlimeBoss.State.attacking)
	attack_duration.start()
	boss.velocity = Vector2.ZERO

func _on_attack_cooldown_timeout() -> void:
	if randf_range(0,1) < 0.25:
		attack_cooldown.start()
		return
	
	if boss.current_state == SlimeBoss.State.idle:
		update_attack()
	else:
		var new_state = await self.change_state
		if new_state == SlimeBoss.State.idle:
			update_attack()
	
func _on_attack_duration_timeout() -> void:
	boss.animated_sprite_2d.modulate = Color("green")
	print("finished attacking")
	change_state.emit(SlimeBoss.State.idle)
	attack_cooldown.start()

func _on_movement_cooldown_timeout() -> void:
	if boss.current_state == SlimeBoss.State.idle:
		update_movement()
	else:
		var new_state = await self.change_state
		if new_state == SlimeBoss.State.idle:
			update_movement()

func _on_movement_duration_timeout() -> void:
	boss.velocity = Vector2.ZERO
	movement_cooldown.start()
	WorldManager.camera.add_shake_trauma(0.25)
	change_state.emit(SlimeBoss.State.idle)
