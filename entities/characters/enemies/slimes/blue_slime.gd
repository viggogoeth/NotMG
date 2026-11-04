extends BaseSlime

signal shooting(direction: Vector2)
signal winding
signal first_target_seen

@export var color: Color = Color(0.0, 0.0, 1.0, 1.0)
@export var enemy_scale: int = 1


@onready var movement_component = $JumpMovementComponent
@onready var all_sprites_node = $Scalables/Sprites
@onready var wind_up_sprite = $Scalables/Sprites/WindUpSprite
@onready var dash_sprite = $Scalables/Sprites/DashSprite
@onready var move_sprite = $Scalables/Sprites/MoveSprite
@onready var animation = $AnimationPlayer

@onready var shoot_attack_component: Node2D = $ShootAttackComponent

var rotating: bool = false

var has_seen_a_target: bool = false

func _ready() -> void:
	super._ready()
	health_component = $Scalables/HealthComponent
	$CollisionShape2D.scale *= enemy_scale
	$Scalables.scale *= enemy_scale
	$Scalables/HitboxComponent.contact_damage = contact_damage
	health_component.set_health(health, health)
	all_sprites_node.modulate = color

func _physics_process(delta: float) -> void:
	if dead: return
	var target = $VisionBoxComponent.get_target()

	var attacking = false
	if not movement_component.moving:
		attacking = shoot_attack_component.try_attack(target)
		
	movement_component.move(target, attacking)
	move_and_slide()

	if rotating and target:
		var dir = global_position.direction_to(target.global_position)
		all_sprites_node.rotation = dir.angle()

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

func _on_has_died() -> void:
	queue_free()

func _on_shooting(direction: Vector2) -> void:
	print("shooting")

func _on_winding() -> void:
	print("winding")


func _on_vision_box_component_body_entered(body: Node2D) -> void:
	if not has_seen_a_target:
		first_target_seen.emit()
		has_seen_a_target = true
