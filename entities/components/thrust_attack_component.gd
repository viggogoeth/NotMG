extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

@export var damage: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func attack(cooldown: float) -> void:
	await get_tree().create_timer(cooldown).timeout
	animated_sprite.play()
	show()
	
	var hit_bodies = get_overlapping_bodies()
	for body in hit_bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
