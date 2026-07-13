extends Node

func get_offset(projectile: Projectile, delta: float) -> Vector2:
	return projectile.global_position + projectile.direction * projectile.speed * delta
