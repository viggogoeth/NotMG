class_name Player3D extends CharacterBody3D

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
@export var movement_speed: float = 5.0
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
var dodge_direction: Vector3

var rotation_speed: float = 2.5

# instance 
const SPEED = 5.0

func _ready() -> void:
	#$MageHandSprite.hide()
	$AnimatedSprite3D.play()
	$AnimatedSprite3D.modulate = Config.player_color
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
		velocity = dodge_direction * DODGE_DISTANCE_PER_FRAME
		#global_position += dodge_direction * DODGE_DISTANCE_PER_FRAME * delta
		move_and_slide()
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var rotation_offset = -$CameraGimball.rotation.y
	
	var c = cos(rotation_offset)
	var s = sin(rotation_offset)
	var x = input_dir.x
	var y = input_dir.y
	input_dir.x = x * c - y * s
	input_dir.y = x * s + y * c
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * (movement_speed + (stats.agility * 0.1))
		velocity.z = direction.z * (movement_speed + (stats.agility * 0.1))
	else:
		velocity.x = move_toward(velocity.x, 0, (movement_speed + (stats.agility * 0.1)))
		velocity.z = move_toward(velocity.z, 0, (movement_speed + (stats.agility * 0.1)))

	move_and_slide()
	
	if Input.is_action_pressed("rotate_left"):
		rotate_y(rotation_speed * delta)
	if Input.is_action_pressed("rotate_right"):
		rotate_y(-rotation_speed * delta)
	if Input.is_action_pressed("rotate_reset"):
		rotation.y = 0
	if Input.is_action_just_pressed("zoom_in"):
		if $CameraGimball/Camera3D.fov > 25:
			$CameraGimball/Camera3D.fov -= 5
	if Input.is_action_just_pressed("zoom_out"):
		if $CameraGimball/Camera3D.fov < 120:
			$CameraGimball/Camera3D.fov += 5
		
	update_mage_hand()
	_handle_animation_direction(input_dir)

func _handle_animation_direction(velocity: Vector2) -> void:
	var sprite = $AnimatedSprite3D
	if velocity.length() == 0:
		sprite.speed_scale = 1.0
		match last_direction:
			Direction.RIGHT:
				sprite.animation = "idle_side"
				sprite.flip_h = false
			Direction.LEFT:
				sprite.animation = "idle_side"
				sprite.flip_h = true
			Direction.UP:
				sprite.animation = "idle_back"
			Direction.DOWN:
				sprite.animation = "idle_front"
			_:
				push_error("Unsupported Direction for 'handle_animation_direction': %s" % last_direction)
	else:
		if velocity.y > 0 and velocity.x == 0:
			sprite.animation = "walk_front"
			last_direction = Direction.DOWN
		elif velocity.y < 0 and velocity.x == 0:
			sprite.animation = "walk_back"
			last_direction = Direction.UP
		
		if velocity.x > 0:
			sprite.animation = "walk_side"
			sprite.flip_h = false
			last_direction = Direction.RIGHT
		elif velocity.x < 0:
			sprite.animation = "walk_side"
			sprite.flip_h = true
			last_direction = Direction.LEFT
		sprite.speed_scale = (movement_speed + (stats.agility * 0.1)) / 5

func update_mage_hand() -> void:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var direction = (mouse_pos - Vector2(global_position.x, global_position.y)).normalized()
	print(direction)
	$MageHandSprite.rotation.y = direction.angle() + PI / 2
	
	#$MageHandSprite.global_position = global_position + Vector3(direction.x, direction.y, 1) * 80
	#projectile_spawn.global_position = $MageHandSprite.global_position
	#$SwordHitbox.global_position = $MageHandSprite.global_position
	#$SwordHitbox.rotation = $MageHandSprite.rotation
	
	if direction.x < 0:
		$MageHandSprite.flip_h = true
	else:
		$MageHandSprite.flip_h = false
