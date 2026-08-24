class_name FishingMinigame extends Node2D

var rod_charge: float = 0
var overcharged: bool = false
var rod_released: bool = false
var on_throw_cooldown: bool = false
var on_reelin_cooldown: bool = true

var has_chasing_fish: bool = false
var chasing_fish: CharacterBody2D

const CAST_SPEED: float = 0.75

@onready var bobber = $FishingRod/Bobber
@onready var bobber_spawn: Vector2 = $FishingRod/BobberSpawn.global_position
@onready var throw_cooldown_timer: Timer = $FishingRod/ThrowCooldownTimer
@onready var reelin_cooldown_timer: Timer = $FishingRod/ReelInCooldownTimer
@onready var charge_bar = $FishingRod/ChargeBarVisuals/ChargeBar
@onready var rod_bobber = $FishingRod/ChargeBarVisuals/RodBobber
@onready var bobber_scare_radius = $FishingRod/Bobber/ScareRadius

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("main_attack"):
		if not rod_released and not on_throw_cooldown:
			release_rod()
		
	if Input.is_action_pressed("main_attack"):
		if rod_released and not on_reelin_cooldown:
			return_rod()
		elif not rod_released and not on_throw_cooldown:
			charge_rod(delta)

func charge_rod(delta: float) -> void:
	if not overcharged and rod_charge < 25:
		rod_charge += 60 * delta
	elif not overcharged and rod_charge < 50:
		rod_charge += 80 * delta
	elif not overcharged and rod_charge < 100:
		rod_charge += 120 * delta
	else:
		overcharged = true
		rod_charge -= 60 * delta
		
	charge_bar.value = rod_charge
		
func release_rod() -> void:
	if rod_charge <= 0:
		rod_charge = 0
		overcharged = false
		return
	
	rod_released = true
	on_reelin_cooldown = true
	reelin_cooldown_timer.start()
	rod_bobber.hide()
	
	var cast_direction = (get_global_mouse_position() - bobber_spawn).normalized()
	var bobber_target_position = bobber_spawn + cast_direction * 9 * rod_charge
	
	var tween = create_tween()
	tween.tween_property(bobber, "global_position", bobber_target_position, CAST_SPEED)
	
	await get_tree().create_timer(CAST_SPEED + 0.1).timeout
	var out_of_bounds = is_out_of_bounds()
	
	if not out_of_bounds:
		scare_fish()
	else:
		print("out of bounds")
		return_rod()

func is_out_of_bounds() -> bool:
	var potential_outside = bobber.get_overlapping_bodies()
	for body in potential_outside:
		if body.is_in_group("outside_water"):
			return true
	return false

func scare_fish() -> void:
	var fish_in_scare_radius = bobber_scare_radius.get_overlapping_bodies()
	for fish in fish_in_scare_radius:
		if fish.has_method("get_scared"):
			fish.get_scared(bobber.global_position)

func return_rod() -> void:
	rod_released = false
	overcharged = false
	rod_charge = 0
	charge_bar.value = 0
	
	has_chasing_fish = false
	if chasing_fish:
		chasing_fish.reel_in(bobber.global_position)
	chasing_fish = null
	
	on_throw_cooldown = true
	throw_cooldown_timer.start()
	
	scare_fish()

	var tween = create_tween()
	tween.tween_property(bobber, "global_position", bobber_spawn, 0.2)

func set_chasing_fish(fish: CharacterBody2D) -> bool:
	if has_chasing_fish or not rod_released or on_reelin_cooldown:
		return false
	
	has_chasing_fish = true
	chasing_fish = fish
	
	return true

func _on_throw_cooldown_timer_timeout() -> void:
	rod_bobber.show()
	on_throw_cooldown = false


func _on_reel_in_cooldown_timer_timeout() -> void:
	on_reelin_cooldown = false
