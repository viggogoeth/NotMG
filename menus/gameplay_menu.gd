extends VBoxContainer

@onready var dash_mode_toggle: Button = $DashMode/DashModeToggle
@onready var screen_shake_toogle: Button = $ScreenShakeMode/ScreenShakeToogle

func _ready() -> void:
	# read from config to get current settings
	#dash_mode_toggle.text = Config.get_gameplay_key_value("dash_follows_mouse")
	if Config.get_gameplay_key_value("dash_follows_mouse"):
		dash_mode_toggle.button_pressed = true
		dash_mode_toggle.text = "Follows Mouse"
	else:
		dash_mode_toggle.text = "Follows Keyboard"
	
	if Config.get_gameplay_key_value("screen_shake_reduced"):
		screen_shake_toogle.button_pressed = true
		screen_shake_toogle.text = "Reduced"
	else:
		screen_shake_toogle.text = "Normal"
	
	

func _on_dash_mode_toggle_toggled(toggled_on: bool) -> void:
	print("follows mouse: ", toggled_on)
	dash_mode_toggle.text = "Follows Mouse" if toggled_on else "Follows Keyboard"
	Config.update_config("Gameplay", "dash_follows_mouse", toggled_on)


func _on_screen_shake_toogle_toggled(toggled_on: bool) -> void:
	print("screen shake: ", toggled_on)
	screen_shake_toogle.text = "Reduced" if toggled_on else "Normal"
	Config.update_config("Gameplay", "screen_shake_reduced", toggled_on)
