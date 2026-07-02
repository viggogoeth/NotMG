extends Area2D

@export_file("*.tscn") var target_world_path: String

var player_in_range: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractPrompt.hide()

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		switch_world()

func switch_world() -> void:
	if target_world_path != "":
		WorldManager.switch_world(target_world_path)
	else:
		print("Warning: No target world path set for this portal!")

func _on_body_entered(body: Node2D) -> void:
	player_in_range = true
	$InteractPrompt.show()


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false
	$InteractPrompt.hide()
