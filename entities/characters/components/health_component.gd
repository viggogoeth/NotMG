extends Node

@export var max_health: float
var current_health: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0:
		get_owner().die()
	
func heal(amount: float) -> void:
	pass
