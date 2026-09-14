extends BaseSlime

var RNG = RandomNumberGenerator.new()

@export var color: Color = Color(1,0,0)
@export var enemy_scale: int = 1


@onready var attack_component = $DashAttackComponent
@onready var movement_component = $JumpMovementComponent
@onready var all_sprites_node = $Scalables/Sprites
@onready var wind_up_sprite = $Scalables/Sprites/WindUpSprite
@onready var dash_sprite = $Scalables/Sprites/DashSprite
@onready var move_sprite = $Scalables/Sprites/MoveSprite
@onready var animation = $AnimationPlayer

var rotating: bool = false

func _ready() -> void:
	super._ready()
	health_component = $Scalables/HealthComponent
	$CollisionShape2D.scale *= enemy_scale
	$Scalables.scale *= enemy_scale
	$Scalables/HitboxComponent.contact_damage = contact_damage
	health_component.set_health(health, health)
	all_sprites_node.modulate = color

func _physics_process(delta: float) -> void:
	var target = $VisionBoxComponent.get_target()

	var dashing = false
	if not movement_component.moving:
		dashing = attack_component.try_attack(target)
		
	if not dashing:
		movement_component.move(target)
	move_and_slide()

	if rotating and target:
		var dir = global_position.direction_to(target.global_position)
		all_sprites_node.rotation = dir.angle()


func set_winding() -> void:
	animation.play("windup")
	hide_sprites()
	wind_up_sprite.show()
	rotating = true

func set_dashing() -> void:
	animation.play("dashing")
	hide_sprites()
	dash_sprite.show()
	rotating = false

func set_moving() -> void:
	animation.play("move")
	hide_sprites()
	move_sprite.show()
	rotating = false
	all_sprites_node.rotation = 0

func set_idle() -> void:
	animation.play("idle")
	hide_sprites()
	move_sprite.show()
	rotating = false
	all_sprites_node.rotation = 0

func hide_sprites() -> void:
	for child in all_sprites_node.get_children():
		child.hide()

func move_start() -> void:
	$Scalables/AnimatedSprite2D.animation = "move"

func move_stop() -> void:
	$Scalables/AnimatedSprite2D.animation = "idle"
