extends BaseEnemy

var can_attack: bool = true
var player_in_attack_range: bool = false
var attacking: bool = false

var sideways: bool = false

@export var sleeping: bool = true

var targets: Array[CharacterBody2D]

@onready var glowing_eyes = $Eyes
@onready var animation_player = $AnimationPlayer
@onready var attack_component = $Melee/ThrustAttackComponent

func _ready() -> void:
	super._ready()
	health_component = $HealthComponent
	health_component.set_health(health, health)
	health_component.hide()
	glowing_eyes.hide()
	resistance = 0.99
	animation_player.play("idle")
	attack_component.damage = contact_damage

func _physics_process(delta: float) -> void:
	if sleeping:
		return
	
	var target = closest_target()
	if target:
		var dir = global_position.direction_to(target.global_position)
		velocity = dir * speed
	else:
		velocity = Vector2(0,0)
	
	if abs(velocity.x) > abs(velocity).y:
		sideways = true
		if velocity.x < 0:
			$Sprites/SideSprites.scale.x = -1
		else:
			$Sprites/SideSprites.scale.x = 1
	else:
		sideways = false
	
	if not player_in_attack_range and not attacking:
		move_and_slide()
		
	if player_in_attack_range and can_attack:
		glowing_eyes.show()
		$Melee/AttackWindup.start()
		animation_player.play("hint")
		can_attack = false
		attacking = true
		set_attack_direction(closest_target())
	
func closest_target() -> CharacterBody2D:
	if targets.is_empty():
		return null
	
	var closest = null
	
	for target in targets:
		if not $VisionBoxComponent.has_line_of_sight(target):
			continue
		if dist(target) < dist(closest):
			closest = target
	return closest

func dist(target: CharacterBody2D) -> float:
	if not is_instance_valid(target):
		return INF
	var dist_x = (global_position.x - target.global_position.x)**2
	var dist_y = (global_position.y - target.global_position.y)**2
	return sqrt(dist_x + dist_y)

func _on_melee_range_body_entered(body: Node2D) -> void:
	player_in_attack_range = true


func _on_melee_range_body_exited(body: Node2D) -> void:
	player_in_attack_range = false


func _on_attack_cooldown_timeout() -> void:
	can_attack = true


func _on_attack_windup_timeout() -> void:
	glowing_eyes.hide()
	attack()
	
func attack() -> void:
	if sideways:
		animation_player.play("side_attack")
		$Sprites/AttackSprite.hide()
		$Sprites/HintSprite.hide()
		$Sprites/SideSprites/SideHintSprite.hide()
		$Sprites/SideSprites/SideAttackSprite.show()
	else:
		animation_player.play("attack")
		$Sprites/AttackSprite.show()
		$Sprites/HintSprite.hide()
		$Sprites/SideSprites/SideHintSprite.hide()
		$Sprites/SideSprites/SideAttackSprite.hide()
	$Melee/AttackCooldown.start()
	$Melee/AttackAnimationTimer.start()
	attack_component.attack(0.14)

func set_attack_direction(target: CharacterBody2D) -> void:
	var direction = global_position.direction_to(target.global_position)
	attack_component.rotation = direction.angle()
	if abs(direction.x) > abs(direction.y):
		sideways = true
		if direction.x < 0:
			$Sprites/SideSprites.scale.x = -1
		else:
			$Sprites/SideSprites.scale.x = 1
	else:
		sideways = false
	print(direction)

func _on_wake_up_range_body_entered(body: Node2D) -> void:
	if not sleeping:
		return
	glowing_eyes.show()
	await get_tree().create_timer(2).timeout
	sleeping = false
	glowing_eyes.hide()
	health_component.show()
	resistance = 0


func _on_vision_box_component_body_entered(body: Node2D) -> void:
	targets.append(body)
	
func _on_vision_box_component_body_exited(body: Node2D) -> void:
	targets.remove_at(targets.find(body))


func _on_attack_animation_timer_timeout() -> void:
	animation_player.play("idle")
	if sideways:
		$Sprites/SideSprites/SideHintSprite.show()
		$Sprites/HintSprite.hide()
	else:
		$Sprites/HintSprite.show()
		$Sprites/SideSprites/SideHintSprite.hide()
	$Sprites/AttackSprite.hide()
	$Sprites/SideSprites/SideAttackSprite.hide()
	attack_component.hide()
	attacking = false
