extends Node

const I_FRAMES: float = 0.4

var movement_speed: float = 400.0

var max_health: float = 100.0
var current_health: float = 100.0
var regen_rate: float = 1

var can_take_damage: bool = true

var attack_cooldown : float = 0.2
var can_attack : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
