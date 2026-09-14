extends BaseSlime

var target_player: CharacterBody2D
var exp_range_player: CharacterBody2D

var RNG = RandomNumberGenerator.new()

@export var color: Color = Color(1,1,1)
@export var enemy_scale: int = 1


@onready var attack_component = $DashAttackComponent

func _ready() -> void:
	super._ready()
	health_component = $Scalables/HealthComponent
	$CollisionShape2D.scale *= enemy_scale
	$Scalables.scale *= enemy_scale
	$Scalables/HitboxComponent.contact_damage = contact_damage
	sprite.play()
	sprite.speed_scale = 0.5 / $JumpMovementComponent.movement_duration
	health_component.set_health(health, health)
	sprite.self_modulate = color

func _physics_process(delta: float) -> void:
	var target = $VisionBoxComponent.get_target()

	var dashing = false
	if not movement_component.moving:
		dashing = attack_component.try_attack(target)
		
	if not dashing:
		movement_component.move(target)
	move_and_slide()

	orient_sprite()
	update_animation()


func move_start() -> void:
	$Scalables/AnimatedSprite2D.animation = "move"

func move_stop() -> void:
	$Scalables/AnimatedSprite2D.animation = "idle"
