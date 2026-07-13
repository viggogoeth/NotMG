extends Node

@export var frequency: float = 25.0
@export var amplitude: float = 35.0


func get_offset(projectile: Projectile, delta: float) -> Vector2:
	var wave_offset: float = sin(projectile.time_elapsed * frequency) * amplitude
	var perpendicular_direction: Vector2 
	if projectile.inverted:
		perpendicular_direction = Vector2(projectile.direction.y, -projectile.direction.x)
	else:
		perpendicular_direction = Vector2(-projectile.direction.y, projectile.direction.x)
	
	var base_forward_pos = projectile.spawn_position + (projectile.direction * projectile.straight_distance_traveled)
	return base_forward_pos + (perpendicular_direction * wave_offset)
	
