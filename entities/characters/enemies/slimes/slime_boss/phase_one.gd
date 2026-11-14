extends Node2D

signal change_state(state: SlimeBoss.State)

@export var slam_projectile: PackedScene

@export var movement_speed: float = 250
@export var attack_movement_speed: float = 600

@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_duration: Timer = $AttackDuration
@onready var attack_intermediate_cooldown: Timer = $AttackIntermediateCooldown
@onready var movement_cooldown: Timer = $MovementCooldown
@onready var movement_duration: Timer = $MovementDuration

@export var boss: SlimeBoss
var player: Player

const ATTACKS_PER_ATTACK: int = 2
var attacks_remaining: int = ATTACKS_PER_ATTACK

func _ready() -> void:
	player = boss.player

func update_movement() -> void:
	var direction = boss.global_position.direction_to(player.global_position)
	boss.velocity = direction * movement_speed
	movement_duration.start()
	change_state.emit(SlimeBoss.State.moving)

func update_attack() -> void:
	boss.animated_sprite_2d.modulate = Color("darkgreen") # TODO: remove (temporary indicator)s
	var direction = boss.global_position.direction_to(player.global_position)
	boss.velocity = direction * attack_movement_speed
	change_state.emit(SlimeBoss.State.attacking)
	attack_duration.start()
	#boss.velocity = Vector2.ZERO

func _on_attack_cooldown_timeout() -> void:
	# make the attack interval less deterministic
	if randf_range(0,1) < 0.25:
		attack_cooldown.start()
		return
	
	if boss.current_state == SlimeBoss.State.idle:
		update_attack()
	else:
		var new_state = await self.change_state
		if new_state == SlimeBoss.State.idle:
			update_attack()
	
func spawn_slam_projectiles(diagonal: bool) -> void:
	var directions = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	for i in range(4):
		var slam_projectile: WaveProjectile = slam_projectile.instantiate()
		slam_projectile.global_position = boss.global_position # TODO: add offset 
		slam_projectile.direction = directions[i]
		slam_projectile.speed = 800
		slam_projectile.range = 2000
		slam_projectile.damage = 15
		get_tree().root.add_child(slam_projectile)
		
		
	
func _on_attack_duration_timeout() -> void:
	boss.animated_sprite_2d.modulate = Color("green")
	print("finished attacking")
	attacks_remaining -= 1
	attack_intermediate_cooldown.start()
	boss.velocity = Vector2.ZERO
	spawn_slam_projectiles(false)
	change_state.emit(SlimeBoss.State.attack_waiting)
		
func _on_movement_cooldown_timeout() -> void:
	if boss.current_state == SlimeBoss.State.idle:
		update_movement()
	else:
		var new_state = await self.change_state
		while new_state != SlimeBoss.State.idle:
			new_state = await self.change_state
		update_movement()
		
func _on_movement_duration_timeout() -> void:
	boss.velocity = Vector2.ZERO
	movement_cooldown.start()
	WorldManager.camera.add_shake_trauma(0.25)
	change_state.emit(SlimeBoss.State.idle)

func _on_attack_intermediate_cooldown_timeout() -> void:
	if attacks_remaining > 0:
		update_attack()
	else:
		attacks_remaining = ATTACKS_PER_ATTACK
		attack_cooldown.start()
		change_state.emit(SlimeBoss.State.idle)
