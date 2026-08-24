extends Node2D

var rod_charge: float = 0
var overcharged: bool = false
var rod_released: bool = false
var on_throw_cooldown: bool = false
var on_reelin_cooldown: bool = true

@onready var bobber: Area2D = $FishingRod/Bobber
@onready var bobber_spawn: Vector2 = $FishingRod/BobberSpawn.global_position
@onready var cooldown_timer: Timer = $FishingRod/ThrowCooldownTimer
@onready var reelin_cooldown_timer: Timer = $FishingRod/ReelInCooldownTimer
@onready var charge_bar = $FishingRod/ChargeBarVisuals/ChargeBar
@onready var rod_bobber = $FishingRod/ChargeBarVisuals/RodBobber

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("main_attack"):
		release_rod()
		
	if Input.is_action_pressed("main_attack"):
		if rod_released:
			return_rod()
		else:
			charge_rod(delta)


func charge_rod(delta: float) -> void:
	if on_throw_cooldown:
		return
	
	if not overcharged and rod_charge < 25:
		rod_charge += 60 * delta
	elif not overcharged and rod_charge < 50:
		rod_charge += 80 * delta
	elif not overcharged and rod_charge < 100:
		rod_charge += 120 * delta
		print(rod_charge)
	else:
		overcharged = true
		rod_charge -= 60 * delta
	
		
	charge_bar.value = rod_charge
		
func release_rod() -> void:
	if rod_released:
		return
	
	if rod_charge <= 0:
		rod_charge = 0
		overcharged = false
		return
	
	print("Released rod at %.2f charge" % rod_charge)
	rod_released = true
	reelin_cooldown_timer.start()
	rod_bobber.hide()
	
	var cast_direction = (get_global_mouse_position() - bobber_spawn).normalized()
	var bobber_target_position = bobber_spawn + cast_direction * 9 * rod_charge
	
	var tween = create_tween()
	tween.tween_property(bobber, "global_position", bobber_target_position, 0.75)

func return_rod() -> void:
	if on_reelin_cooldown:
		return
		
	bobber.global_position = bobber_spawn
	
	rod_released = false
	overcharged = false
	on_reelin_cooldown = true
	rod_charge = 0
	charge_bar.value = 0
	
	on_throw_cooldown = true
	cooldown_timer.start()

func _on_throw_cooldown_timer_timeout() -> void:
	rod_bobber.show() # TODO: fix when its shown
	on_throw_cooldown = false


func _on_reel_in_cooldown_timer_timeout() -> void:
	on_reelin_cooldown = false
