class_name SlimeBoss extends CharacterBody2D

@export var player: Player

@export var max_health: float = 1000.0
var current_health: float = max_health

@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer

@onready var sprites: Node2D = $Sprites

enum State {
	hiding,
	invulnerable,
	idle,
}

enum Phase {
	one,
	two,
}

var current_state = State.hiding
var current_phase = Phase.one

func _ready() -> void:
	progress_bar.max_value = max_health
	progress_bar.value = current_health

func _physics_process(delta: float) -> void:
	#if current_state == State.hiding: return
	move_and_slide()

func take_damage(amount: float) -> void:
	if current_state == State.invulnerable: return
	current_health -= amount
	progress_bar.value -= amount
	if current_health <= health_threshold(current_phase):
		goto_next_phase(current_phase)

func health_threshold(phase: Phase) -> float:
	match phase:
		Phase.one:
			return max_health * 0.75
		Phase.two:
			return max_health * 0.5
		_:
			return 0

func goto_next_phase(phase: Phase) -> void:
	match phase:
		Phase.one:
			current_phase = Phase.two
			print("Going to phase two")
			current_state = State.invulnerable
			invulnerability_timer.start()
			create_tween().tween_property(sprites, "modulate", Color("red"), 5)
		_:
			print("Next phase not implemented")
			pass


func _on_invulnerability_timer_timeout() -> void:
	current_state = State.idle
	sprites.modulate = Color("white")
