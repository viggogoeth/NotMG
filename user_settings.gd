class_name UserSettings extends Resource

enum DashMode {MOUSE, KEYS}
@export var dash_mode: DashMode = DashMode.MOUSE

@export var player_color: Color = Color(1,0,0)

@export var key_binds  = {
	"move_up": "W"
	}


