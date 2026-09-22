class_name KeyBindMenu extends VBoxContainer

@export var key_button_scene: PackedScene

const ACTION_NAMES: Dictionary[String, String] = {
		"g_dodge": "Dodge",
		"g_move_left": "Move Left",
		"g_move_right": "Move Right",
		"g_move_down": "Move Down",
		"g_move_up": "Move Up",
		"g_interact": "Interact",
		"g_inventory": "Inventory",
		"g_pause": "Pause Menu",
		"g_zoom_in": "Zoom In",
		"g_zoom_out": "Zoom Out",
	}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_keybind_options()

func add_keybind_options() -> void:
	var actions = InputMap.get_actions()
	for act in actions:
		if not act.begins_with("g_"):		# godot has default input mappings :(
			continue
		var binding = InputMap.action_get_events(act)[0]
		var key_button_node = key_button_scene.instantiate()
		key_button_node.action_name = act
		key_button_node.display_name = ACTION_NAMES.get(act,act)
		key_button_node.current_bind = binding.as_text()
		add_child(key_button_node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_reset_pressed() -> void:
	var default_bindings = Config.get_default_keybinds()
	var bind_buttons = get_tree().get_nodes_in_group("bind_button")

	#print(default_bindings)
	print(bind_buttons)

	for act in default_bindings:
		Config.remap(act, default_bindings[act])
		for button in bind_buttons:
			if button.action_name == act:
				button.update_bind(default_bindings[act].as_text())
