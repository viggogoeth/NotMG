extends BaseEnemy

var target_player: CharacterBody2D
var exp_range_player: CharacterBody2D

var RNG = RandomNumberGenerator.new()

@export var color: Color = Color(1,1,1)
@export var enemy_scale: int = 1

func _ready() -> void:
	super._ready()
	health_component = $Scalables/HealthComponent
	$CollisionShape2D.scale *= enemy_scale
	$Scalables.scale *= enemy_scale
	$LineOfSight.collide_with_areas = true
	$Scalables/HitboxComponent.contact_damage = contact_damage
	$Scalables/AnimatedSprite2D.play()
	$Scalables/AnimatedSprite2D.speed_scale = 0.5 / $JumpMovementComponent.movement_duration
	health_component.set_health(health, health)
	$Scalables/AnimatedSprite2D.self_modulate = color

func _physics_process(delta: float) -> void:
	var target = $VisionBoxComponent.get_target()
			
	$JumpMovementComponent.move(self, target)
		
	if velocity.x < 0:
		$Scalables/AnimatedSprite2D.flip_h = true
	else:
		$Scalables/AnimatedSprite2D.flip_h = false
	
	if $JumpMovementComponent.moving:
		$Scalables/AnimatedSprite2D.animation = "move"
	else:
		$Scalables/AnimatedSprite2D.animation = "idle"


func _on_vision_body_entered(body: Node2D) -> void:
	pass

func _on_vision_body_exited(body: Node2D) -> void:
	pass

func move_start() -> void:
	$Scalables/AnimatedSprite2D.animation = "move"

func move_stop() -> void:
	$Scalables/AnimatedSprite2D.animation = "idle"
