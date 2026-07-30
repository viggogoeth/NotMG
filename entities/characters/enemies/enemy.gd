extends CharacterBody2D

var target_player: CharacterBody2D
var exp_range_player: CharacterBody2D

@export var enemy_id: String

@export var speed = 400.0
@export var health: float = 100.0

var dead: bool = false

var RNG = RandomNumberGenerator.new()

@export var resistance: float = 0.15
@export var contact_damage: float = 5.0

@export var exp_amount: float = 10.0

@export var color: Color = Color(1,1,1)
@export var enemy_scale: int = 1

const LOOT_BAG_SCENE = preload("res://entities/loot_bag.tscn")

func _ready() -> void:
	$CollisionShape2D.scale *= enemy_scale
	$Scalables.scale *= enemy_scale
	$LineOfSight.collide_with_areas = true
	$Scalables/HitboxComponent.contact_damage = contact_damage
	$Scalables/AnimatedSprite2D.play()
	$Scalables/AnimatedSprite2D.speed_scale = 0.5 / $JumpMovementComponent.movement_duration
	$Scalables/HealthComponent.set_health(health, health)
	$Scalables/AnimatedSprite2D.self_modulate = color

func _physics_process(delta: float) -> void:
	var target = target_player
	
	if target_player:
		print("has target_player")
		$LineOfSight.target_position = target_player.global_position - $LineOfSight.global_position
		if $LineOfSight.is_colliding():
			target = null 
			
	$JumpMovementComponent.move(self, target)
		
	if velocity.x < 0:
		$Scalables/AnimatedSprite2D.flip_h = true
	else:
		$Scalables/AnimatedSprite2D.flip_h = false
	
	if $JumpMovementComponent.moving:
		$Scalables/AnimatedSprite2D.animation = "move"
	else:
		$Scalables/AnimatedSprite2D.animation = "idle"
	
func take_damage(amount: float) -> void:
	var resist_adjusted_damage = amount * (1 - resistance)
	$Scalables/HealthComponent.take_damage(resist_adjusted_damage)
	
func die() -> void:
	if dead:
		return
	dead = true
	exp_range_player.add_exp(exp_amount)
	
	var drop = DropTables.get_drop(self.enemy_id)
	if drop.size() > 0:
		var lootbag: LootContainer = LOOT_BAG_SCENE.instantiate()
		lootbag.global_position = global_position
		lootbag.add_items(drop)
		get_tree().current_scene.add_child.call_deferred(lootbag)
	
	queue_free()

func _on_vision_body_entered(body: Node2D) -> void:
	target_player = body
	exp_range_player = body # TODO: give this a different hitbox

func _on_vision_body_exited(body: Node2D) -> void:
	target_player = null
	exp_range_player = null

func move_start() -> void:
	$Scalables/AnimatedSprite2D.animation = "move"

func move_stop() -> void:
	$Scalables/AnimatedSprite2D.animation = "idle"
