class_name PlayerCamera extends Camera2D

@export var shake_decay = 0.8
@export var max_shake_offset = Vector2(100, 75)
@export var max_shake_roll = 0.1

@onready var noise = FastNoiseLite.new()
var noise_y = 0

var shake_trauma = 0.0
var shake_trauma_power = 2

@export var target: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldManager.camera = self
	zoom.x = WorldManager.zoom_level
	zoom.y = WorldManager.zoom_level
	
	# shake
	randomize()
	#noise.seed = randi() dont listen to freaks on the internet
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.25
	noise.fractal_octaves = 2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("g_zoom_in"):
		if zoom.x < 5:
			zoom *= 1.2
	if event.is_action_pressed("g_zoom_out"):
		if zoom.x > 0.2:
			zoom /= 1.2
	WorldManager.zoom_level = zoom.x

func _process(delta: float) -> void:
	if target:
		global_position = target.global_position
	if shake_trauma:
		shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		shake()

func add_shake_trauma(amount: float) -> void:
	if Config.get_key_value("Gameplay", "screen_shake_reduced"):
		shake_trauma = min(shake_trauma + amount/3, 0.33)
	else:
		shake_trauma = min(shake_trauma + amount, 1)

func shake() -> void:
	var amount = pow(shake_trauma, shake_trauma_power)
	noise_y += 1
	rotation = max_shake_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_shake_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_shake_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
