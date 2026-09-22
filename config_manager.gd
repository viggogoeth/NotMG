extends Node

var player_color: Color = Color("red")

var default_keybind_map: Dictionary[String, InputEvent]

func _ready():
	_init_cfg()

func _init_cfg() -> void:
	var config = ConfigFile.new()

	var err = config.load("user://user_config.cfg")

	_store_default_keybinds()
	if err == OK:
		_load_keybinds_from_config(config)
		return	# config already exists
	
	print("Creating new config: 'user_config.cfg'")

	config.set_value("Gameplay", "player_color", Color("red"))
	config.set_value("Gameplay", "dash_mode", "mouse")
	_add_default_keybinds(config)
	config.save("user://user_config.cfg")

func _store_default_keybinds() -> void:
	default_keybind_map = {}
	
	var actions = InputMap.get_actions()
	for act in actions:
		if not act.begins_with("g_"):		# godot has default input mappings :(
			continue
		var bind = InputMap.action_get_events(act)[0]
		default_keybind_map.set(act, bind)


func _add_default_keybinds(config: ConfigFile) -> void:
	var actions = InputMap.get_actions()
	for act in actions:
		if not act.begins_with("g_"):		# godot has default input mappings :(
			continue
		var key = InputMap.action_get_events(act)[0]
		config.set_value("Keybindings", act, key)

func _load_keybinds_from_config(config: ConfigFile) -> void:
	print("Loading keybindings")
	for act in config.get_section_keys("Keybindings"):
		var bind = config.get_value("Keybindings", act)
		self.remap(act, bind)

func remap(action: String, key: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key)

	var config = ConfigFile.new()
	var err = config.load("user://user_config.cfg")
	if err != OK:
		print("Failed to load config")
		return

	config.set_value("Keybindings", action, key)
	config.save("user://user_config.cfg")

func get_default_keybinds() -> Dictionary[String, InputEvent]:
	return default_keybind_map
