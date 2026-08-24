class_name Bobber extends Area2D

@export var fishing_minigame: FishingMinigame
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_chasing_fish(fish: CharacterBody2D) -> bool:
	return fishing_minigame.set_chasing_fish(fish)
