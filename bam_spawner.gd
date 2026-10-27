extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

@export var bam_scene: PackedScene

func create_bam() -> Bam:
	var new_bam = bam_scene.instantiate()
	return new_bam

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
