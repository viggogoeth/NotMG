extends Node

var target: Node2D = null
var turn_speed: float = 3.0

func get_offset(projectile: Projectile, delta: float) -> Vector2:
	target = projectile.get_closest_target()
	if is_instance_valid(target):
		var target_dir = (target.global_position - projectile.global_position).normalized()
		projectile.direction = projectile.direction.slerp(target_dir, turn_speed * delta)
	
	return projectile.global_position + projectile.direction * projectile.speed * delta

	
