extends VBoxContainer

@onready var dash_mode_toggle: Button = $DashMode/DashModeToggle

func _ready() -> void:
	# read from config to get current settings
	#dash_mode_toggle.text = Config.get_gameplay_key_value("dash_follows_mouse")
	if Config.get_gameplay_key_value("dash_follows_mouse"):
		dash_mode_toggle.button_pressed = true
		dash_mode_toggle.text = "Follows Mouse"
	else:
		dash_mode_toggle.text = "Follows Keyboard"

func _on_dash_mode_toggle_toggled(toggled_on: bool) -> void:
	print("follows mouse: ", toggled_on)
	dash_mode_toggle.text = "Follows Mouse" if toggled_on else "Follows Keyboard"
	Config.update_config("Gameplay", "dash_follows_mouse", toggled_on)
