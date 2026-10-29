extends BaseSlime

var target_player: CharacterBody2D
var exp_range_player: CharacterBody2D

var RNG = RandomNumberGenerator.new()

@onready var sprite = $Scalables/AnimatedSprite2D
@onready var movement_component = $JumpMovementComponent

@export var color: Color = Color(1,1,1)
@export var enemy_scale: int = 1

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
	base_damage_sound_pitch = 1.0 / enemy_scale # this implies that the "regular" slimes are scaled to 2x (base is then 0.5)

func _physics_process(delta: float) -> void:
	if dead: return
	var target = $VisionBoxComponent.get_target()
			
	movement_component.move(target)
	move_and_slide()
		
func set_moving() -> void:
	sprite.animation = "move"

func set_idle() -> void:
	sprite.animation = "idle"

func move_start() -> void:
	$Scalables/AnimatedSprite2D.animation = "move"

func move_stop() -> void:
	$Scalables/AnimatedSprite2D.animation = "idle"

func _on_has_died() -> void:
	$Scalables/AnimatedSprite2D.animation = "dying"
	await get_tree().create_timer(1).timeout
	queue_free()
