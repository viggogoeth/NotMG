class_name Bobber extends Area2D

@export var fishing_minigame: FishingMinigame

@onready var shadow = $BobberVisual/Shadow
@onready var overlay = $BobberVisual/WaterOverlay
@onready var water_ring_animation = $WaterRings

var ring_animation_playing: bool = false
var water_hit_position: Vector2

var thrown: bool = false

const BOB_RATE: float = 6.0

const MIN_HEIGHT: float = 0.0
const MAX_HEIGHT: float = 5.0
var current_height: float = 0
var going_up: bool = true

func _process(delta: float) -> void:
	if thrown:
		animate_bobber(delta)
		overlay.show()
	else:
		overlay.hide()
		
	if ring_animation_playing:
		water_ring_animation.global_position = water_hit_position

func set_chasing_fish(fish: CharacterBody2D) -> bool:
	return fishing_minigame.set_chasing_fish(fish)

func return_bobber() -> void:
	fishing_minigame.return_rod()

func animate_bobber(delta: float) -> void:
	if current_height >= MAX_HEIGHT:
		going_up = false

	if current_height <= MIN_HEIGHT:
		going_up = true
		
	if going_up:
		_go_up(delta)
	else:
		_go_down(delta)
		
func _go_down(delta: float) -> void:
	global_position.y -= BOB_RATE * delta
	current_height -= BOB_RATE * delta

func _go_up(delta: float) -> void:
	global_position.y += BOB_RATE * delta
	current_height += BOB_RATE * delta	

func hit_water() -> void:
	water_ring_animation.show()
	water_ring_animation.play("rings")
	thrown = true
	ring_animation_playing = true
	water_hit_position = global_position


func _on_water_rings_animation_finished() -> void:
	water_ring_animation.hide()
	ring_animation_playing = false
