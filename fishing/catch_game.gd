extends CanvasLayer

var current_fish_texture: Texture2D

var playing: bool = false
@onready var start_timer = $GetReadyTimer

@export var fishing_minigame: FishingMinigame

@onready var charge_bar = $CatchBar
@onready var catch_box = $CatchBox
@onready var bar_bottom = $BarBottom.global_position

@onready var fish_sprite = $Fish/FishSprite
@onready var fish_animation = $Fish/AnimationPlayer
@onready var fish = $Fish

@onready var reel_sign = $ReelSign
@onready var get_ready_sign = $GetReadySign

const CHARGE_RATE: float = 17.0
const CHARGE_DECAY_RATE: float = 13.0
const BASE_CHARGE: float = 15.0
var current_charge: float = BASE_CHARGE
var overlapping: bool = false

var catch_bar_offset_ratio: float = 0.0
const CATCH_BAR_SPEED: float = 50.0

var fish_offset_ratio: float = 0.0
var fish_float_speed: float = 5.0
var fish_jump_speed: float = 30.0
var fish_moving_up: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	get_ready_sign.hide()
	reel_sign.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if playing:
		_play_catch_game(delta)

func _play_catch_game(delta: float) -> void:
	if Input.is_action_pressed("main_attack") and catch_bar_offset_ratio <= 100.0:
		catch_bar_offset_ratio += delta * CATCH_BAR_SPEED
	else:
		catch_bar_offset_ratio -= delta * CATCH_BAR_SPEED
		if catch_bar_offset_ratio <= 0:
			catch_bar_offset_ratio = 0
	
	_update_catch_box_position()
	_update_fish_offset(delta)
	
	_update_catch_charge(delta)

func _update_catch_charge(delta: float) -> void:
	if overlapping:
		current_charge += delta * CHARGE_RATE
	elif current_charge >= 0.0:
		current_charge -= delta * CHARGE_DECAY_RATE
		
	charge_bar.value = current_charge
	
	if current_charge >= 100.0:
		_finish_catch()
		
	if current_charge <= 0.0:
		_abandon_catch()

func _update_catch_box_position() -> void:
	catch_box.global_position.y = bar_bottom.y - catch_bar_offset_ratio * 6

func _update_fish_offset(delta: float) -> void:
	if fish_moving_up and fish_offset_ratio <= 100.0:
		fish_offset_ratio += fish_float_speed * delta
	elif fish_offset_ratio >= 0.0:
		fish_offset_ratio -= fish_float_speed * delta
		
	fish.global_position.y = bar_bottom.y - fish_offset_ratio * 6

func start_catch_game(fish: Fish) -> void:
	if fish:
		current_fish_texture = fish.texture
		fish_sprite.texture = fish.texture
		fish_animation.play("flopping")
		$Fish/ColorRect.hide()
	else:
		$Fish/ColorRect.show()
	start_timer.start()
	
	get_ready_sign.show()
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(get_ready_sign, "scale", Vector2(1.2,1.2), 1.5)
	tween.tween_property(get_ready_sign, "scale", Vector2(1,1), 0.1)
	
	toggle_catch_game()

func toggle_catch_game() -> void:
	fishing_minigame.toggle_physics()
	
	visible = not visible

func _abandon_catch() -> void:
	# TODO: implement
	_finish_catch()

func _finish_catch() -> void:
	current_charge = BASE_CHARGE
	fish_offset_ratio = 0.0
	catch_bar_offset_ratio = 0.0
	playing = false
	
	_update_catch_box_position()
	_update_fish_offset(0)
	charge_bar.value = BASE_CHARGE
	
	toggle_catch_game()

func _on_move_timer_timeout() -> void:
	if not playing:
		return
		
	var rand = RandomNumberGenerator.new()
	var charge_ratio = fish_offset_ratio / 100.0
	if rand.randf() < charge_ratio:
		fish_moving_up = false
	else:
		fish_moving_up = true
	
	if rand.randf() < 0.25:
		var new_offset_ratio: float
		if fish_moving_up:
			new_offset_ratio = max(0, min(100, fish_offset_ratio + fish_jump_speed))
		else:
			new_offset_ratio = max(0, min(100, fish_offset_ratio - fish_jump_speed))
		
		var tween = create_tween()
		tween.set_ease(tween.EASE_IN_OUT)
		tween.tween_property(self, "fish_offset_ratio", new_offset_ratio, 0.5)


func _on_catch_box_area_exited(area: Area2D) -> void:
	overlapping = false


func _on_catch_box_area_entered(area: Area2D) -> void:
	overlapping = true


func _on_get_ready_timer_timeout() -> void:
	playing = true
	get_ready_sign.hide()
	reel_sign.show()
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(reel_sign, "scale", Vector2(1.3, 1.3), 0.5)
	tween.tween_property(reel_sign, "visible", false, 0.1)
	#reel_sign.hide()
