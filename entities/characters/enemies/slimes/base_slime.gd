class_name BaseSlime extends BaseEnemy

@onready var sprite = $Scalables/AnimatedSprite2D
@onready var movement_component = $JumpMovementComponent

func _ready():
	pass

func orient_sprite() -> void:
	if velocity.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func update_animation() -> void:
	if movement_component.moving:
		sprite.animation = "move"
	else:
		sprite.animation = "idle"

