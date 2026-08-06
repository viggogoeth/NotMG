extends BaseEnemy

var can_attack: bool = true
var player_in_attack_range: bool = false

@export var sleeping: bool = true

var targets: Array[CharacterBody2D]

func _ready() -> void:
	health_component = $HealthComponent
	health_component.set_health(health, health)
	$Melee/Eyes.hide()
	resistance = 0.99
	$Melee/AttackAnimation.hide()

func _physics_process(delta: float) -> void:
	if sleeping:
		return
	
	var target = closest_target()
	if target:
		var dir = global_position.direction_to(target.global_position)
		velocity = dir * speed
		# temp for magehand
		$Melee/AttackAnimation.rotation = dir.angle() + PI / 2
	else:
		velocity = Vector2(0,0)
	
	if not player_in_attack_range:
		move_and_slide()
		
	if player_in_attack_range and can_attack:
		$Melee/Eyes.show()
		$Melee/AttackWindup.start()
		can_attack = false
	
func closest_target() -> CharacterBody2D:
	if targets.is_empty():
		return null
	
	var closest = targets[0]
	
	for target in targets:
		if dist(target) < dist(closest):
			closest = target
	return closest if $VisionBoxComponent.has_line_of_sight(closest) else null

func dist(target: CharacterBody2D) -> float:
	var dist_x = (global_position.x - target.global_position.x)**2
	var dist_y = (global_position.y - target.global_position.y)**2
	return sqrt(dist_x + dist_y)

func _on_melee_range_body_entered(body: Node2D) -> void:
	player_in_attack_range = true


func _on_melee_range_body_exited(body: Node2D) -> void:
	player_in_attack_range = false


func _on_attack_cooldown_timeout() -> void:
	can_attack = true


func _on_attack_indicator_animation_finished() -> void:
	$Melee/AttackAnimation.stop()


func _on_attack_windup_timeout() -> void:
	$Melee/AttackAnimation.play()
	$Melee/AttackCooldown.start()
	$Melee/Eyes.hide()
	attack()
	
func attack() -> void:
	var bodies = $Melee/DamageRange.get_overlapping_bodies()
	for body in bodies:
		body.take_damage(contact_damage)


func _on_wake_up_range_body_entered(body: Node2D) -> void:
	if not sleeping:
		return
	$Melee/Eyes.show()
	await get_tree().create_timer(2).timeout
	sleeping = false
	$Melee/Eyes.hide()
	$Melee/AttackAnimation.show()
	resistance = 0


func _on_vision_box_component_body_entered(body: Node2D) -> void:
	print("Body entered: ", body)
	targets.append(body)
	
func _on_vision_box_component_body_exited(body: Node2D) -> void:
	targets.remove_at(targets.find(body))
