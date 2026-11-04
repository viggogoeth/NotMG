class_name Projectile extends Area2D

const STRAIGHT_PATTERN = preload("res://entities/projectiles/patterns/straight_pattern.gd")
const SINE_PATTERN = preload("res://entities/projectiles/patterns/sine_pattern.gd")
const HOMING_PATTERN = preload("res://entities/projectiles/patterns/homing_pattern.gd")

@export var on_hit_particles: PackedScene

@export var color: Color = Color("ff86ffff")

@export var speed: float = 750.0
@export var max_range: float = 800.0

var time_elapsed: float = 0.0
@onready var spawn_position: Vector2 = global_position

@export var damage: float = 10.0

var inverted: bool = false

var direction: Vector2
var straight_distance_traveled: float = 0.0

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color = color

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	
	var offset = $Pattern.get_offset(self, delta)
	position = offset
	
	straight_distance_traveled += speed * delta
	if straight_distance_traveled >= max_range:
		queue_free()

func set_pattern(pattern: String) -> void:
	if pattern == "sine_pattern":
		$Pattern.set_script(SINE_PATTERN)
	if pattern == "homing_pattern":
		$Pattern.set_script(HOMING_PATTERN)
	else:
		$HomingRadius.queue_free()
	if pattern == "straight_pattern":
		$Pattern.set_script(STRAIGHT_PATTERN)

func _on_body_entered(body: Node2D) -> void:
	# damage logic
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	_add_particles_to_tree()
	
	queue_free()

func _add_particles_to_tree() -> void:
	var particles = on_hit_particles.instantiate()
	particles.position = global_position
	particles.set_backsplash(direction.normalized())
	particles.start_particles()
	particles.color = color
	
	get_tree().current_scene.add_child(particles)

func get_closest_target() -> Node2D:
	var targets: Array[Node2D] = $HomingRadius.get_overlapping_bodies()
	if targets.is_empty():
		return null
	
	var closest_node: Node2D = null
	var shortest_distance_squared: float = INF 
	
	for target in targets:
		var distance_squared: float = global_position.distance_squared_to(target.global_position)
		if distance_squared < shortest_distance_squared:
			shortest_distance_squared = distance_squared
			closest_node = target
		
	return closest_node

func set_color(color: Color) -> void:
	self.color = color

func set_collision_mask_by_shooter(shooter_type: String) -> void:
	# 1 = player
	# 2 = world
	# 3 = enemy
	# 4 = super enemy
	if shooter_type == "enemy":
		set_collision_mask_value(1, true)
		set_collision_mask_value(3, false)
		set_collision_mask_value(4, false)
	elif shooter_type == "player":
		set_collision_mask_value(1, false)
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, true)
	elif shooter_type == "super_enemy":
		set_collision_mask_value(1, true)
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, false)
