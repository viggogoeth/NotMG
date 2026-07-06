extends Area2D

@export_file("*.tscn") var target_world_path: String

var player_in_range: bool = false
@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	$InteractPrompt.hide()

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		switch_world()

func switch_world() -> void:
	if target_world_path != "":
		_save_data()
		await get_tree().process_frame
		WorldManager.switch_world(target_world_path)
	else:
		print("Warning: No target world path set for this portal!")

func _on_body_entered(body: Node2D) -> void:
	player_in_range = true
	$InteractPrompt.show()


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false
	$InteractPrompt.hide()

func _save_data() -> void:
	var data = SaveData.new()
	data.current_health = player.current_health
	data.current_level = player.current_level
	data.current_exp = player.current_exp
	
	data.current_scene = target_world_path

	ResourceSaver.save(data, "user://save_data.tres")
	print("Saving data.")
