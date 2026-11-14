class_name WaveProjectile extends Area2D

@onready var hurtbox: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

@export var texture: Resource

@export var damage: float
@export var speed: float = 100
@export var direction: Vector2 = Vector2(0.5,0.5)
@export var range: float = 2000

var distance_travelled: float = 0

func _ready() -> void:
	sprite.texture = texture
	var size = Vector2(sprite.texture.get_width(), sprite.texture.get_height())
	size *= 0.9 # make it easier to dodge
	hurtbox.shape.size = size
	rotation = direction.angle() - PI/2 # offset 90 degress (sprite orientation)
	
func _process(delta: float) -> void:
	global_position += direction * speed * delta
	distance_travelled += speed * delta
	if distance_travelled >= range:
		queue_free()

func _on_body_entered(body: Player) -> void:
	body.take_damage(damage)
	queue_free()
