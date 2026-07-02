extends CharacterBody2D

const SPEED = 300.0

var movement_update_cooldown: float = 0.8
var should_update_movement: bool = true

var RNG = RandomNumberGenerator.new()

const RESISTANCE: float = 0.15
const CONTACT_DAMAGE: float = 5.0

func _ready() -> void:
	$MovementTimer.wait_time = movement_update_cooldown
	$HealthComponent.max_health = 100.0
	$HealthComponent.current_health = 100.0

func _physics_process(delta: float) -> void:
	if should_update_movement:
		var dir_x = RNG.randf_range(-1,1)
		var dir_y = RNG.randf_range(-1,1)
		var direction = Vector2(dir_x, dir_y)
		
		velocity = direction * SPEED
		should_update_movement = false
		
		var update_cooldown = RNG.randf_range(0.3, 0.8)
		$MovementTimer.wait_time = update_cooldown
		$MovementTimer.start()
	
	move_and_slide()

func _on_movement_timer_timeout() -> void:
	should_update_movement = true

func take_damage(amount: float) -> void:
	var resist_adjusted_damage = amount * (1 - RESISTANCE)
	$HealthComponent.take_damage(resist_adjusted_damage)
	
func die() -> void:
	queue_free()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(CONTACT_DAMAGE)
