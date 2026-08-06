extends Area2D

var target_player: CharacterBody2D
var exp_range_player: CharacterBody2D

func has_line_of_sight(target: CharacterBody2D) -> bool:
	if target:
		#$LineOfSight.force_shapecast_update()
		$LineOfSight.target_position = target.global_position - $LineOfSight.global_position
		if $LineOfSight.is_colliding():
			return false
		else:
			return true
	else:
		return false
	
func get_target() -> CharacterBody2D:
	if has_line_of_sight(target_player):
		return target_player
	return null
	
func _on_body_entered(body: Node2D) -> void:
	target_player = body
	exp_range_player = body # TODO: give this a different hitbox

func _on_body_exited(body: Node2D) -> void:
	target_player = null
	exp_range_player = null
