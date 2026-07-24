class_name Player extends CharacterBody2D

@export var projectile_scene : PackedScene = preload("res://entities/projectiles/projectile.tscn")
@onready var projectile_spawn : Marker2D = $ProjectileSpawn

const I_FRAMES: float = 0.4
const DODGE_COOLDOWN: float = 2
const DODGE_FRAMES: float = 0.2
const DODGE_DISTANCE_PER_FRAME: float = 1800

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

var can_dodge: bool = true
var dodging: bool = false
var dodge_direction: Vector2

func _ready() -> void:
	$MageHandSprite.hide()
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.modulate = Config.player_color
	if is_instance_valid(equipped_weapon.item_in_slot):
		$AttackTimer.wait_time = equipped_weapon.item_in_slot.base_attack_rate / (stats.dexterity / 10)
	$IFrameTimer.wait_time = I_FRAMES
	$DodgeTimer.wait_time = DODGE_FRAMES
	$DodgeCooldown.wait_time = DODGE_COOLDOWN
	$HealthComponent.set_health(max_health, current_health)
	can_attack = true
	can_take_damage = true
	
func _physics_process(delta: float) -> void:
	if dodging:
		global_position += dodge_direction * DODGE_DISTANCE_PER_FRAME * delta
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * (movement_speed + (stats.agility * 5))

	_handle_animation_direction(velocity)

	move_and_slide()
	
	update_mage_hand()
	
	if Input.is_action_pressed("main_attack") and is_instance_valid(equipped_weapon.item_in_slot) and can_attack:
		can_attack = false
		var attack_cooldown = equipped_weapon.item_in_slot.base_attack_rate / ((stats.dexterity + 100.0) / 110.0)
		$AttackTimer.wait_time = attack_cooldown
		$AttackTimer.start()
		_attack()
		$MageHandSprite.play()
		$MageHandSprite.show()
		var weapon: WeaponData = equipped_weapon.item_in_slot
		$MageHandSprite.speed_scale = 0.5 / attack_cooldown
		
	if Input.is_action_just_released("main_attack"):
		$MageHandSprite.stop()
		#await get_tree().create_timer(0.6).timeout # let magehand stay for a second
		$MageHandSprite.hide()
		
	if Input.is_action_just_pressed("dodge") and not dodging and can_dodge:
		_dodge()
		print("Dodging")
		

func _dodge() -> void:
	dodge_direction = (get_global_mouse_position() - global_position).normalized()
	dodging = true
	can_take_damage = false
	can_dodge = false
	$DodgeTimer.start()
	$DodgeCooldown.start()
	$Hud.dodge_used()
	$AnimatedSprite2D.modulate = Color(1.207, 0.212, 1.154, 1.0) # TODO: fix when sprite is changed

func _attack() -> void:
	var weapon = equipped_weapon.item_in_slot
	if weapon.type == "sword":
		_sword_attack()
		return
	
	var invert_projectile = false
	for num_projectiles in weapon.projectiles_count:
		var projectile = projectile_scene.instantiate()
		projectile.damage = weapon.base_damage * (0.1 * stats.strength)
		projectile.max_range = weapon.range * 100
		
		var attack_direction = (get_global_mouse_position() - global_position).normalized()
		projectile.direction = attack_direction
		projectile.global_position = projectile_spawn.global_position
		
		projectile.set_pattern(weapon.pattern)
		projectile.inverted = invert_projectile
		invert_projectile = not invert_projectile
		get_owner().add_child(projectile)
	
func _sword_attack() -> void:
	$SwordHitbox/CollisionShape2D.disabled = false
	

func _handle_animation_direction(velocity: Vector2) -> void:
	if velocity.length() == 0:
		$AnimatedSprite2D.speed_scale = 1.0
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
		$AnimatedSprite2D.speed_scale = movement_speed / 400


func _on_attack_timer_timeout() -> void:
	can_attack = true

func take_damage(amount: float) -> void:
	if can_take_damage:
		$HealthComponent.take_damage(amount)
		can_take_damage = false
		current_health = $HealthComponent.current_health
		$IFrameTimer.start()
		
		var tween = create_tween()
		var old_scale = $AnimatedSprite2D.scale
		tween.tween_property($AnimatedSprite2D, "scale", old_scale*1.2, 0.1)
		tween.tween_property($AnimatedSprite2D, "scale", old_scale, 0.05)

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

func update_mage_hand() -> void:
	# if the direction is calculated based on the mage_hand position
	#var abs_vec = abs(get_global_mouse_position() - global_position)
	#$MageHandSprite.flip_v = abs_vec.x < 80 and abs_vec.y < 80
	#if abs_vec.x < 80 and abs_vec.y < 80:
	#	if $MageHandSprite.offset.y > 0:
	#		$MageHandSprite.offset.y = -$MageHandSprite.offset.y
	#else:
	#	if $MageHandSprite.offset.y < 0:
	#			$MageHandSprite.offset.y = -$MageHandSprite.offset.y
		
	var direction = (get_global_mouse_position() - global_position).normalized()
	$MageHandSprite.rotation = direction.angle() + PI / 2
	$MageHandSprite.global_position = global_position + direction * 80
	projectile_spawn.global_position = $MageHandSprite.global_position
	$SwordHitbox.global_position = $MageHandSprite.global_position
	$SwordHitbox.rotation = $MageHandSprite.rotation
	

func _on_i_frame_timer_timeout() -> void:
	can_take_damage = true
	_overlapping_enemies_damage()

func _overlapping_enemies_damage() -> void:
	var bodies = $HitBox.get_overlapping_bodies()
	if not bodies.is_empty():
		var body = bodies[0]
		take_damage(body.contact_damage)

func _on_regen_timer_timeout() -> void:
	$HealthComponent.heal(regen_rate)
	current_health = $HealthComponent.current_health


func _on_dodge_cooldown_timeout() -> void:
	can_dodge = true
	$Hud.dodge_ready()


func _on_dodge_timer_timeout() -> void:
	can_take_damage = true
	dodging = false
	_overlapping_enemies_damage()
	$AnimatedSprite2D.modulate = Config.player_color


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(equipped_weapon.damage)
