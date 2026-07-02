extends Area2D

@export var speed: float = 750.0
@export var max_range: float = 800.0

@export var frequency: float = 25.0
@export var amplitude: float = 35.0
var time_elapsed: float = 0.0
@onready var spawn_position: Vector2 = global_position

const DAMAGE: float = 15.0

var inversed: bool = false

var direction: Vector2
var straight_distance_traveled: float = 0.0

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	
	var wave_offset: float = sin(time_elapsed * frequency) * amplitude
	var perpendicular_direction: Vector2 
	if inversed:
		perpendicular_direction = Vector2(direction.y, -direction.x)
	else:
		perpendicular_direction = Vector2(-direction.y, direction.x)
	
	var base_forward_pos = spawn_position + (direction * straight_distance_traveled)
	global_position = base_forward_pos + (perpendicular_direction * wave_offset)
	
	# For sprite rotation
	var next_wave_offset = sin((time_elapsed + 0.01) * frequency) * amplitude
	var next_forward_pos = spawn_position + (direction * (straight_distance_traveled + (speed * 0.01)))
	var next_global_pos = next_forward_pos + (perpendicular_direction * next_wave_offset)
	rotation = (next_global_pos - global_position).angle()
	
	
	straight_distance_traveled += speed * delta
	if straight_distance_traveled >= max_range:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# damage logic
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)
		
	queue_free()
	
