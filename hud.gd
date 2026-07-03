extends CanvasLayer

@export var default_healthbar_width: int = 320
@export var default_healthbar_height: int = 32

@export var default_expbar_width: int = 320
@export var default_expbar_height: int = 16

var last_level: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_level = PlayerVariables.current_level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_healthbar()
	_update_expbar()

func _update_healthbar() -> void:
	if PlayerVariables.current_health < 25:
		$Healthbar/Healthbar.color = Color(1.0, 0.0, 0.0, 1.0)
	elif PlayerVariables.current_health < 50:
		$Healthbar/Healthbar.color = Color(1.0, 1.0, 0.0, 1.0)
	else:
		$Healthbar/Healthbar.color = Color(0.0, 1.0, 0.0, 1.0)
	
	var remaining_health_percent = PlayerVariables.current_health / PlayerVariables.max_health
	var updated_healthbar_width = default_healthbar_width * remaining_health_percent
	$Healthbar/Healthbar.size = Vector2(updated_healthbar_width, default_healthbar_height)
	
	var health_number_text = "%.1f / " % PlayerVariables.current_health
	health_number_text += "%.1f" % PlayerVariables.max_health
	$Healthbar/HealthNumber.text = health_number_text

func _update_expbar() -> void:
	var remaining_exp_percent = PlayerVariables.current_exp / PlayerVariables.needed_exp_to_level()
	var updated_expbar_width = default_expbar_width * remaining_exp_percent
	$Expbar/Expbar.size = Vector2(updated_expbar_width, default_expbar_height)
	
	
	$Expbar/Label.text = "%d" % PlayerVariables.current_level
	if PlayerVariables.current_level > last_level:
		#$Expbar/Label.scale = Vector2(1.3, 1.3)
		#await get_tree().create_timer(0.1).timeout
		#$Expbar/Label.scale = Vector2(1, 1)
		var tween = create_tween()
		tween.tween_property($Expbar/Label, "scale", Vector2(1.5, 1.5), 0.5)
		tween.tween_property($Expbar/Label, "scale", Vector2(2.5, 2.5), 0.6)
		tween.tween_property($Expbar/Label, "scale", Vector2(3.0, 3.0), 0.5)
		tween.tween_property($Expbar/Label, "scale", Vector2(1.0, 1.0), 0.2)
	last_level = PlayerVariables.current_level
