extends VBoxContainer

@onready var dash_mode_toggle: Button = $DashMode/DashModeToggle

func _ready() -> void:
	# read from config to get current settings
	dash_mode_toggle.text = Config.get_gameplay_key_value("dash_mode")

func _on_dash_mode_toggle_pressed() -> void:
	var mode: String
	if dash_mode_toggle.text == "Follow Mouse":
		mode = "Follow Keyboard"
	else:
		mode = "Follow Mouse"
	dash_mode_toggle.text = mode
	Config.update_config("Gameplay", "dash_mode", mode)
