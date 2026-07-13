class_name Projectile extends Area2D

const SINE_PATTERN = preload("res://entities/projectiles/patterns/sine_pattern.gd")
const HOMING_PATTERN = preload("res://entities/projectiles/patterns/homing_pattern.gd")

@export var speed: float = 750.0
@export var max_range: float = 800.0

var time_elapsed: float = 0.0
@onready var spawn_position: Vector2 = global_position

@export var damage: float = 25.0

var inverted: bool = false

var direction: Vector2
var straight_distance_traveled: float = 0.0

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

func _on_body_entered(body: Node2D) -> void:
	# damage logic
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
	queue_free()
	
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
