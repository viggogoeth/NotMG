extends Node

var player_color: Color = Color("red")

func _ready():
	_init_cfg()

func _init_cfg() -> void:
	var config = ConfigFile.new()

	var err = config.load("user://user_config.cfg")

	if err == OK:
		print("Config: 'user_config.cfg' already exists, aborting init")
		return	# config already exists
	
	print("Creating new config: 'user_config.cfg'")

	config.set_value("Gameplay", "player_color", Color("red"))
	
	config.save("user://user_config.cfg")
