class_name Player extends CharacterBody2D

@export var projectile_scene : PackedScene = preload("res://entities/projectiles/projectile.tscn")
@onready var projectile_spawn : Marker2D = $ProjectileSpawn

const I_FRAMES: float = 0.4

var can_attack: bool = true
@export var current_health: float = 100.0
@export var max_health: float = 100.0
@export var regen_rate: float = 2.5
var can_take_damage: bool = true
@export var movement_speed: float = 400.0
@export var is_dead: bool = false
@export var current_level: int = 1
@export var current_exp: float = 0.0

# stats
@export var stats: PlayerStats

# items
@export var equipped_weapon: SlotData
@export var inventory: InventoryData

# For animation
enum Direction {LEFT, RIGHT, UP, DOWN}
var last_direction = Direction.DOWN

func _ready() -> void:
	$AnimatedSprite2D.play()
	if is_instance_valid(equipped_weapon.item_in_slot):
		$AttackTimer.wait_time = equipped_weapon.item_in_slot.base_attack_rate / (stats.dexterity / 10)
	$IFrameTimer.wait_time = I_FRAMES
	$HealthComponent.set_health(max_health, current_health)
	can_attack = true
	can_take_damage = true
	
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * (movement_speed + (stats.agility * 5))

	_handle_animation_direction(velocity)

	move_and_slide()
	
	if Input.is_action_pressed("main_attack") and is_instance_valid(equipped_weapon.item_in_slot) and can_attack:
		can_attack = false
		$AttackTimer.wait_time = equipped_weapon.item_in_slot.base_attack_rate / (stats.dexterity / 10)
		$AttackTimer.start()
		_attack()
		
func _attack():
	var weapon = equipped_weapon.item_in_slot
	var invert_projectile = false
	for num_projectiles in weapon.projectiles_count:
		var projectile = projectile_scene.instantiate()
		projectile.damage = weapon.base_damage * (0.1 * stats.strength)
		projectile.max_range = weapon.range * 100
		
		var attack_direction = (get_global_mouse_position() - projectile_spawn.global_position).normalized()
		projectile.direction = attack_direction
		projectile.global_position = projectile_spawn.global_position
		
		projectile.set_pattern(weapon.pattern)
		projectile.inverted = invert_projectile
		invert_projectile = not invert_projectile
		get_owner().add_child(projectile)
	

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
		current_health = $HealthComponent.current_health
		$IFrameTimer.start()
		
		var tween = create_tween()
		tween.tween_property($AnimatedSprite2D, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property($AnimatedSprite2D, "scale", Vector2(1, 1), 0.05)

func set_health(max_health: float, current_health: float) -> void:
	self.current_health = current_health
	self.max_health = max_health
	$HealthComponent.current_health = current_health
	$HealthComponent.max_health = max_health

func die() -> void:
	is_dead = true
	print("THE PLAYER IS DEAD")

func _level_up() -> void:
	current_exp = current_exp - needed_exp_to_level()
	current_level += 1
	stats.increase_all(1)

func needed_exp_to_level() -> float:
	return CommonFuncs._fib(current_level) * 100.0

func add_exp(amount: float) -> void:
	current_exp += amount
	if current_exp >= needed_exp_to_level():
		_level_up()

func _on_i_frame_timer_timeout() -> void:
	can_take_damage = true
	
	var bodies = $HitBox.get_overlapping_bodies()
	if not bodies.is_empty():
		var body = bodies[0]
		take_damage(body.contact_damage)
		

func _on_regen_timer_timeout() -> void:
	$HealthComponent.heal(regen_rate)
	current_health = $HealthComponent.current_health
