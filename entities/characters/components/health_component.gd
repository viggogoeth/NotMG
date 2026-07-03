extends Node2D

@export var healthbar_shown: bool = true

@export var max_health: float
var current_health: float

var default_healthbar_width: int = 64
var default_healthbar_height: int = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HealthbarBackground.visible = healthbar_shown
	$Healthbar.visible = healthbar_shown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(amount: float) -> void:
	current_health -= amount
	
	if current_health <= 0:
		get_owner().die()
	
	_update_healthbar()
	
func heal(amount: float) -> void:
	current_health += amount
	current_health = min(current_health, max_health)
	_update_healthbar()

func set_health(max: float, current: float) -> void:
	current_health = current
	max_health = max
	_update_healthbar()

func _update_healthbar() -> void:
	if current_health < 25:
		$Healthbar.color = Color(1.0, 0.0, 0.0, 1.0)
	elif current_health < 50:
		$Healthbar.color = Color(1.0, 1.0, 0.0, 1.0)
	else:
		$Healthbar.color = Color(0.0, 1.0, 0.0, 1.0)
	
	var remaining_health_percent = current_health / max_health
	var updated_healthbar_width = default_healthbar_width * remaining_health_percent
	$Healthbar.size = Vector2(updated_healthbar_width, default_healthbar_height)
